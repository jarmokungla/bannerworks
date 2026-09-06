extends RefCounted
## Versioned, checksummed JSON. Keep the previous good save if the new write fails.

const SAVE_PATH = "user://bannerworks.json"

static func save_game(simulation, path: String = SAVE_PATH) -> Error:
	var payload = JSON.stringify(simulation.snapshot())
	var envelope = JSON.stringify({"sha256":payload.sha256_text(), "payload":payload})
	var temp = path + ".tmp"
	var file = FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(envelope)
	file.flush()
	var write_error = file.get_error()
	file.close()
	if write_error != OK:
		return write_error
	if FileAccess.file_exists(path) and not read_state(path, simulation.data).is_empty():
		var backup_error = DirAccess.copy_absolute(path, path + ".bak")
		if backup_error != OK:
			return backup_error
	return DirAccess.rename_absolute(temp, path)

static func load_game(simulation, path: String = SAVE_PATH) -> String:
	for candidate in [path, path + ".bak"]:
		var state = read_state(candidate, simulation.data)
		if not state.is_empty() and simulation.restore(state):
			return "backup" if candidate.ends_with(".bak") else "loaded"
	return "missing" if not FileAccess.file_exists(path) else "invalid"

static func read_state(path: String, data: Dictionary) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var envelope = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not envelope is Dictionary:
		return {}
	if not envelope.get("payload") is String or not envelope.get("sha256") is String:
		return {}
	if envelope.payload.sha256_text() != envelope.sha256:
		return {}
	var state = JSON.parse_string(envelope.payload)
	if not state is Dictionary or not valid_state(state, data):
		return {}
	return state

static func has_keys(value: Dictionary, keys: Array) -> bool:
	for key in keys:
		if not value.has(key):
			return false
	return true

static func integer(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value))

static func nonnegative_number(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= 0

static func valid_inventory(value, data: Dictionary) -> bool:
	if not value is Dictionary:
		return false
	for item in value:
		if not data.items.has(item) or not integer(value[item]) or value[item] < 0:
			return false
	return true

static func valid_path(value, roads: Dictionary) -> bool:
	if not value is Array:
		return false
	for key in value:
		if not key is String or not roads.has(key):
			return false
	return true

static func valid_state(state: Dictionary, data: Dictionary) -> bool:
	if not has_keys(state, ["version", "buildings", "roads", "routes", "people", "backpack",
		"crates", "next_id", "next_person", "elapsed", "mission_complete", "paused"]):
		return false
	if state.version != 1 or not state.buildings is Array or not state.roads is Dictionary:
		return false
	if not state.routes is Array or not state.people is Array or not state.crates is Array:
		return false
	if not valid_inventory(state.backpack, data) or not integer(state.next_id) or not integer(state.next_person):
		return false
	if not nonnegative_number(state.elapsed):
		return false
	if not state.paused is bool or not state.mission_complete is bool:
		return false
	var ids = {}
	for building in state.buildings:
		if not building is Dictionary or not has_keys(building, ["id", "kind", "x", "y", "rotation",
			"inventory", "progress", "recipe", "status", "training_person", "enabled"]):
			return false
		if not integer(building.id) or building.id <= 0 or ids.has(building.id) or not data.buildings.has(building.kind):
			return false
		if not valid_inventory(building.inventory, data):
			return false
		for key in ["x", "y", "rotation", "training_person"]:
			if not integer(building[key]):
				return false
		if not nonnegative_number(building.progress) or not building.enabled is bool or not building.status is String:
			return false
		if building.rotation < 0 or building.rotation > 3 or building.x < 0 or building.y < 0:
			return false
		if building.x + data.buildings[building.kind].size > 36 or building.y + data.buildings[building.kind].size > 36:
			return false
		if building.recipe != "" and not data.recipes.has(building.recipe):
			return false
		ids[building.id] = true
		if building.id >= state.next_id:
			return false
	for key in state.roads:
		if not key is String:
			return false
		var parts = key.split(",")
		if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
			return false
	for route in state.routes:
		if not route is Dictionary or not has_keys(route, ["source", "target", "item", "path", "position", "cargo", "returning", "wait", "enabled", "status"]):
			return false
		if not ids.has(route.source) or not ids.has(route.target) or not data.items.has(route.item):
			return false
		# Idle routes may retain stale paths after a road is removed; they recalculate on load.
		if not route.path is Array or not integer(route.cargo) or route.cargo < 0 or route.cargo > 4:
			return false
		if not nonnegative_number(route.position) or not nonnegative_number(route.wait) or not route.status is String:
			return false
		for key in route.path:
			if not key is String:
				return false
		if route.cargo > 0 or route.position > 0:
			if not valid_path(route.path, state.roads) or route.path.is_empty():
				return false
		if not route.returning is bool or not route.enabled is bool:
			return false
	var person_ids = {}
	for person in state.people:
		if not person is Dictionary or not has_keys(person, ["id", "name", "location", "destination", "skills", "gear", "path", "position"]):
			return false
		if not integer(person.id) or person_ids.has(person.id) or person.id >= state.next_person:
			return false
		if not person.name is String or not person.skills is Array or not person.gear is Array:
			return false
		if not nonnegative_number(person.position) or not integer(person.location) or not integer(person.destination):
			return false
		if not valid_path(person.path, state.roads):
			return false
		if person.path.is_empty() and not ids.has(person.location):
			return false
		if not person.path.is_empty() and not ids.has(person.destination):
			return false
		person_ids[person.id] = true
	for crate in state.crates:
		if not crate is Dictionary or not has_keys(crate, ["x", "y", "inventory"]):
			return false
		if not integer(crate.x) or not integer(crate.y) or not valid_inventory(crate.inventory, data):
			return false
	return true
