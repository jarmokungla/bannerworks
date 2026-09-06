extends RefCounted
## Authoritative state; no scenes, sprites, input or wall-clock dependencies.
## Every material belongs to one inventory or a cart. People keep their identity.

const MAP_SIZE = 36
const BAG_SLOTS = 12
const STEP = 0.1
const SAVE_VERSION = 1
const DIRECTIONS = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]

var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data.json"))
var buildings: Array = []
var roads: Dictionary = {}
var routes: Array = []
var people: Array = []
var backpack: Dictionary = {}
var crates: Array = []
var next_id = 1
var next_person = 1
var elapsed = 0.0
var mission_complete = false
var paused = false
var path_cache: Dictionary = {}

func tile_key(tile: Vector2i) -> String:
	return "%d,%d" % [tile.x, tile.y]

func key_tile(key: String) -> Vector2i:
	var parts = key.split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

func terrain(tile: Vector2i) -> String:
	if tile.x < 0 or tile.y < 0 or tile.x >= MAP_SIZE or tile.y >= MAP_SIZE:
		return "edge"
	var river_x = 27 + int(sin(float(tile.y) * 0.25) * 2.0)
	if tile.x >= river_x and tile.x <= river_x + 2:
		return "water"
	if (tile.x <= 2 or tile.y <= 2) and (tile.x * 7 + tile.y * 11) % 5 != 0:
		return "forest"
	if tile.x >= 17 and tile.x <= 20 and tile.y >= 5 and tile.y <= 7:
		return "iron"
	return "grass"

func definition(building: Dictionary) -> Dictionary:
	return data.buildings[building.kind]

func get_building(id: int) -> Dictionary:
	for building in buildings:
		if building.id == id:
			return building
	return {}

func building_at(tile: Vector2i) -> Dictionary:
	for building in buildings:
		var n = int(definition(building).size)
		if Rect2i(building.x, building.y, n, n).has_point(tile):
			return building
	return {}

func port(building: Dictionary) -> Vector2i:
	var n = int(definition(building).size)
	var p = Vector2i(building.x, building.y)
	match int(building.rotation):
		0: return p + Vector2i(n / 2, n)
		1: return p + Vector2i(-1, n / 2)
		2: return p + Vector2i(n / 2, -1)
		_: return p + Vector2i(n, n / 2)

func slots_used(inventory: Dictionary) -> int:
	var count = 0
	for item in inventory:
		count += int(ceil(float(inventory[item]) / float(data.items[item].stack)))
	return count

func room(inventory: Dictionary, item: String, slots: int) -> int:
	var stack = int(data.items[item].stack)
	var quantity = int(inventory.get(item, 0))
	var remainder = (stack - quantity % stack) % stack
	return maxi(0, slots - slots_used(inventory)) * stack + remainder

func add_items(inventory: Dictionary, item: String, amount: int, slots: int) -> int:
	var accepted = mini(maxi(amount, 0), room(inventory, item, slots))
	if accepted > 0:
		inventory[item] = int(inventory.get(item, 0)) + accepted
	return accepted

func remove_items(inventory: Dictionary, item: String, amount: int) -> int:
	var removed = mini(maxi(amount, 0), int(inventory.get(item, 0)))
	if removed > 0:
		inventory[item] -= removed
		if inventory[item] == 0:
			inventory.erase(item)
	return removed

func can_pay(inventory: Dictionary, cost: Dictionary) -> bool:
	for item in cost:
		if int(inventory.get(item, 0)) < int(cost[item]):
			return false
	return true

func pay(inventory: Dictionary, cost: Dictionary) -> bool:
	if not can_pay(inventory, cost):
		return false
	for item in cost:
		remove_items(inventory, item, int(cost[item]))
	return true

func transfer(building_id: int, item: String, amount: int, to_backpack: bool) -> int:
	var building = get_building(building_id)
	if building.is_empty() or not data.items.has(item):
		return 0
	var source = building.inventory if to_backpack else backpack
	var target = backpack if to_backpack else building.inventory
	var capacity = BAG_SLOTS if to_backpack else int(definition(building).slots)
	var moved = mini(mini(maxi(0, amount), int(source.get(item, 0))), room(target, item, capacity))
	remove_items(source, item, moved)
	add_items(target, item, moved, capacity)
	return moved

func placement_error(kind: String, tile: Vector2i, rotation: int) -> String:
	if not data.buildings.has(kind):
		return "Unknown building."
	if kind == "shield_school" and not mission_complete:
		return "Complete Border Patrol to unlock the Shield School."
	var n = int(data.buildings[kind].size)
	var touches_iron = false
	for x in range(n):
		for y in range(n):
			var t = tile + Vector2i(x, y)
			if terrain(t) in ["water", "forest", "edge"]:
				return "Choose open ground."
			if terrain(t) == "iron":
				touches_iron = true
			if not building_at(t).is_empty() or roads.has(tile_key(t)):
				return "Buildings and roads cannot overlap."
			for crate in crates:
				if Vector2i(crate.x, crate.y) == t:
					return "Collect the pickup crate before building here."
			for other in buildings:
				if port(other) == t:
					return "Leave the neighboring building's gate clear."
	if kind == "mine" and not touches_iron:
		return "Place the mine on the gray iron deposit."
	var probe = {"kind":kind, "x":tile.x, "y":tile.y, "rotation":rotation}
	var gate = port(probe)
	if terrain(gate) in ["water", "forest", "edge"] or not building_at(gate).is_empty():
		return "Rotate so the gate faces open ground."
	return ""

func create_building(kind: String, tile: Vector2i, rotation: int = 0) -> Dictionary:
	var recipes = data.buildings[kind].get("recipes", [])
	var building = {"id":next_id, "kind":kind, "x":tile.x, "y":tile.y,
		"rotation":rotation, "inventory":{}, "progress":0.0,
		"recipe":recipes[0] if not recipes.is_empty() else "", "status":"Ready",
		"training_person":0, "enabled":true}
	next_id += 1
	buildings.append(building)
	path_cache.clear()
	return building

func place(kind: String, tile: Vector2i, rotation: int) -> String:
	var error = placement_error(kind, tile, rotation)
	if not error.is_empty():
		return error
	if not pay(backpack, data.buildings[kind].cost):
		return "Collect construction materials into your backpack first."
	create_building(kind, tile, rotation)
	return ""

func add_road(tile: Vector2i) -> String:
	var key = tile_key(tile)
	if roads.has(key):
		return ""
	if terrain(tile) in ["water", "forest", "edge"] or not building_at(tile).is_empty():
		return "Roads need clear ground."
	if not pay(backpack, {"timber":1}):
		return "Roads cost 1 timber per tile from your backpack."
	roads[key] = true
	path_cache.clear()
	return ""

func erase_road(tile: Vector2i) -> String:
	var key = tile_key(tile)
	if not roads.has(key):
		return "No road here."
	# Edits are blocked on occupied paths; no stranded cargo or teleported people.
	for route in routes:
		if route.path.has(key) and (route.cargo > 0 or route.position > 0.0):
			return "Let this cart return first (pause its route to stop new loads)."
	for person in people:
		if person.path.has(key):
			return "A resident is using this road."
	roads.erase(key)
	refund({"timber":1}, tile)
	path_cache.clear()
	return ""

func refund(items: Dictionary, tile: Vector2i) -> void:
	var overflow = {}
	for item in items:
		var left = int(items[item]) - add_items(backpack, item, int(items[item]), BAG_SLOTS)
		if left > 0:
			overflow[item] = left
	if not overflow.is_empty():
		crates.append({"x":tile.x, "y":tile.y, "inventory":overflow})

func dismantle(id: int) -> String:
	var building = get_building(id)
	if building.is_empty():
		return "Select a building."
	if building.kind == "hall":
		return "Keep your founding Town Hall."
	for person in people:
		if person.location == id or person.destination == id:
			return "Send the residents to another building first."
	for route in routes:
		if route.source == id or route.target == id:
			return "Remove this building's routes first."
	var materials = building.inventory.duplicate()
	for item in definition(building).cost:
		materials[item] = int(materials.get(item, 0)) + int(definition(building).cost[item])
	refund(materials, Vector2i(building.x, building.y))
	buildings.erase(building)
	path_cache.clear()
	return ""

func collect_crate(tile: Vector2i) -> int:
	var moved = 0
	for crate in crates.duplicate():
		if Vector2i(crate.x, crate.y) != tile:
			continue
		for item in crate.inventory.keys():
			var taken = add_items(backpack, item, int(crate.inventory[item]), BAG_SLOTS)
			remove_items(crate.inventory, item, taken)
			moved += taken
		if crate.inventory.is_empty():
			crates.erase(crate)
	return moved

func find_path(source_id: int, target_id: int) -> Array:
	var cache_key = "%d>%d" % [source_id, target_id]
	if path_cache.has(cache_key):
		return path_cache[cache_key]
	var source = get_building(source_id)
	var target = get_building(target_id)
	if source.is_empty() or target.is_empty():
		return []
	var first = tile_key(port(source))
	var last = tile_key(port(target))
	if not roads.has(first) or not roads.has(last):
		return []
	var queue = [first]
	var previous = {first:""}
	var index = 0
	while index < queue.size():
		var here = queue[index]
		index += 1
		if here == last:
			var path = [last]
			while path[0] != first:
				path.push_front(previous[path[0]])
			path_cache[cache_key] = path
			return path
		for direction in DIRECTIONS:
			var neighbor = tile_key(key_tile(here) + direction)
			if roads.has(neighbor) and not previous.has(neighbor):
				previous[neighbor] = here
				queue.append(neighbor)
	path_cache[cache_key] = []
	return []

func add_route(source_id: int, target_id: int, item: String) -> String:
	if source_id == target_id:
		return "Choose a different destination."
	if not data.items.has(item):
		return "Choose cargo."
	var path = find_path(source_id, target_id)
	if path.is_empty():
		return "Connect both gold gates with a continuous road first."
	for existing in routes:
		if existing.source == source_id and existing.target == target_id and existing.item == item:
			return "That delivery route already exists."
	routes.append({"source":source_id, "target":target_id, "item":item, "path":path,
		"position":0.0, "cargo":0, "returning":false, "wait":2.0, "enabled":true,
		"status":"Loading"})
	return ""

func remove_route(index: int) -> String:
	if index < 0 or index >= routes.size():
		return "Route no longer exists."
	var route = routes[index]
	if route.cargo > 0 or route.position > 0.0:
		route.enabled = false
		return "Route paused. Let its cart unload and return, then remove it."
	routes.remove_at(index)
	return ""

func recruit(location: int) -> Dictionary:
	var person = {"id":next_person, "name":"Resident %d" % next_person,
		"location":location, "destination":0, "skills":[], "gear":[],
		"path":[], "position":0.0}
	next_person += 1
	people.append(person)
	return person

func send_person(person_id: int, target_id: int) -> String:
	for person in people:
		if person.id != person_id:
			continue
		if not person.path.is_empty():
			return "This resident is already walking."
		if person.location == target_id:
			return "Already here."
		var path = find_path(person.location, target_id)
		if path.is_empty():
			return "Connect the buildings' gates by road first."
		person.path = path.duplicate()
		person.position = 0.0
		person.destination = target_id
		person.location = 0
		return ""
	return "Resident not found."

func unit_name(person: Dictionary) -> String:
	if person.skills.has("Sword") and person.skills.has("Shield"):
		return "Man-at-Arms"
	if person.skills.has("Sword"):
		return "Swordsman"
	if person.skills.has("Shield"):
		return "Shieldbearer"
	return "Peasant"

func complete_mission() -> String:
	if mission_complete:
		return "Border Patrol is complete. Try training a Man-at-Arms."
	var ready = 0
	for person in people:
		if person.skills.has("Sword") and person.path.is_empty():
			ready += 1
	if ready < 3:
		return "Train 3 swordsmen for Border Patrol (%d/3)." % ready
	mission_complete = true
	return ""

func tick(delta: float) -> void:
	if paused:
		return
	elapsed += delta
	for route in routes:
		_tick_route(route, delta)
	for person in people:
		if not person.path.is_empty():
			person.position += delta * 1.4
			if person.position >= person.path.size() - 1:
				person.location = person.destination
				person.destination = 0
				person.path = []
				person.position = 0.0
	for building in buildings:
		_tick_building(building, delta)

func _tick_route(route: Dictionary, delta: float) -> void:
	var source = get_building(route.source)
	var target = get_building(route.target)
	if source.is_empty() or target.is_empty():
		route.status = "Missing endpoint"
		return
	if route.wait > 0.0:
		route.wait = maxf(0.0, route.wait - delta)
		return
	if route.returning:
		route.status = "Returning empty"
		route.position = maxf(0.0, route.position - delta)
		if route.position == 0.0:
			route.returning = false
			route.wait = 2.0
		return
	if route.cargo == 0:
		if not route.enabled:
			route.status = "Paused"
			return
		route.path = find_path(route.source, route.target).duplicate()
		if route.path.is_empty():
			route.status = "Road disconnected"
			return
		var space = room(target.inventory, route.item, int(definition(target).slots))
		if space <= 0:
			route.status = "Destination full"
			return
		route.cargo = remove_items(source.inventory, route.item, mini(4, space))
		if route.cargo == 0:
			route.status = "Waiting for cargo"
			return
		route.status = "Delivering"
		route.position = 0.0
	route.position = minf(route.position + delta, float(route.path.size() - 1))
	if route.position >= route.path.size() - 1:
		var accepted = add_items(target.inventory, route.item, int(route.cargo), int(definition(target).slots))
		route.cargo -= accepted
		if route.cargo == 0:
			route.returning = true
			route.wait = 2.0
		else:
			route.status = "Destination full — cargo held"

func _tick_building(building: Dictionary, delta: float) -> void:
	if not building.enabled:
		building.status = "Paused"
		return
	var spec = definition(building)
	if building.kind == "hall":
		if people.size() >= 12:
			building.status = "Housing full (12)"
			building.progress = 0.0
		elif not can_pay(building.inventory, {"food":6}):
			building.status = "Needs 6 rations"
			building.progress = 0.0
		else:
			building.status = "Attracting a peasant"
			building.progress += delta
			if building.progress >= 30.0:
				pay(building.inventory, {"food":6})
				recruit(building.id)
				building.progress = 0.0
		return
	if spec.has("skill"):
		_tick_school(building, delta)
		return
	if building.recipe == "":
		building.status = "Local storage"
		return
	var recipe = data.recipes[building.recipe]
	if not can_pay(building.inventory, recipe["in"]):
		building.status = "Waiting for materials"
		building.progress = 0.0
		return
	var proposed = building.inventory.duplicate()
	pay(proposed, recipe["in"])
	for item in recipe.out:
		proposed[item] = int(proposed.get(item, 0)) + int(recipe.out[item])
	if slots_used(proposed) > int(spec.slots):
		building.status = "Output full"
		return
	building.status = "Producing " + data.items[building.recipe].name.to_lower()
	building.progress += delta
	if building.progress >= float(recipe.seconds):
		# Commit input consumption and output together. No partial recipe state.
		building.inventory = proposed
		building.progress = 0.0

func _tick_school(building: Dictionary, delta: float) -> void:
	var spec = definition(building)
	var student: Dictionary = {}
	for person in people:
		if person.location == building.id and not person.skills.has(spec.skill):
			student = person
			break
	if student.is_empty():
		building.status = "Needs an untrained resident"
		building.progress = 0.0
		building.training_person = 0
		return
	if building.training_person != student.id:
		building.training_person = student.id
		building.progress = 0.0
	var cost = {"food":2}
	cost[spec.equipment] = 1
	if not can_pay(building.inventory, cost):
		building.status = "Needs equipment + 2 rations"
		building.progress = 0.0
		return
	building.status = "Training " + student.name
	building.progress += delta
	if building.progress >= 20.0:
		pay(building.inventory, cost)
		student.skills.append(spec.skill)
		student.gear.append(spec.equipment)
		building.progress = 0.0

func set_recipe(id: int, recipe: String) -> void:
	var building = get_building(id)
	if not building.is_empty() and definition(building).get("recipes", []).has(recipe):
		building.recipe = recipe
		building.progress = 0.0

func new_game() -> void:
	buildings.clear()
	roads.clear()
	routes.clear()
	people.clear()
	crates.clear()
	path_cache.clear()
	next_id = 1
	next_person = 1
	elapsed = 0.0
	mission_complete = false
	paused = false
	backpack = {"timber":100, "bars":12, "food":12}
	var hall = create_building("hall", Vector2i(9, 6))
	hall.inventory = {"food":12}
	var farm = create_building("farm", Vector2i(5, 7))
	farm.inventory = {"food":8}
	var lumber = create_building("lumber", Vector2i(5, 11), 2)
	lumber.inventory = {"timber":30}
	create_building("mine", Vector2i(17, 6))
	for x in range(6, 19):
		roads[tile_key(Vector2i(x, 9))] = true
	roads["6,10"] = true
	roads["18,8"] = true
	add_route(farm.id, hall.id, "food")
	for i in range(3):
		recruit(hall.id)

func snapshot() -> Dictionary:
	return {"version":SAVE_VERSION, "buildings":buildings.duplicate(true),
		"roads":roads.duplicate(true), "routes":routes.duplicate(true),
		"people":people.duplicate(true), "backpack":backpack.duplicate(true),
		"crates":crates.duplicate(true), "next_id":next_id, "next_person":next_person,
		"elapsed":elapsed, "mission_complete":mission_complete, "paused":paused}

func restore(state: Dictionary) -> bool:
	# Only called after SaveStore validates the entire payload.
	if int(state.get("version", -1)) != SAVE_VERSION:
		return false
	buildings = state.buildings.duplicate(true)
	roads = state.roads.duplicate(true)
	routes = state.routes.duplicate(true)
	people = state.people.duplicate(true)
	backpack = state.backpack.duplicate(true)
	crates = state.crates.duplicate(true)
	next_id = int(state.next_id)
	next_person = int(state.next_person)
	elapsed = float(state.elapsed)
	mission_complete = state.mission_complete
	paused = state.paused
	path_cache.clear()
	return true
