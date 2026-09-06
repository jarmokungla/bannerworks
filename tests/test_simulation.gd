extends SceneTree

const Simulation = preload("res://scripts/simulation.gd")
const SaveStore = preload("res://scripts/save_store.gd")
var failures = 0
var checks = 0

func _initialize() -> void:
	test_transfer_and_construction()
	test_delivery_conservation()
	test_training_identity()
	test_save_recovery()
	test_refund_and_pause()
	print("Bannerworks: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("TEST FAILED: " + message)

func advance(sim, seconds: float) -> void:
	for i in range(int(ceil(seconds / sim.STEP))):
		sim.tick(sim.STEP)

func total(sim, item: String) -> int:
	var amount = int(sim.backpack.get(item, 0))
	for building in sim.buildings:
		amount += int(building.inventory.get(item, 0))
	for route in sim.routes:
		if route.item == item:
			amount += int(route.cargo)
	for crate in sim.crates:
		amount += int(crate.inventory.get(item, 0))
	for person in sim.people:
		amount += person.gear.count(item)
	return amount

func test_transfer_and_construction() -> void:
	var sim = Simulation.new()
	sim.new_game()
	var lumber = sim.buildings[2]
	var before = total(sim, "timber")
	check(sim.transfer(lumber.id, "timber", 10, true) == 10, "Take from local building")
	check(total(sim, "timber") == before, "Transfer conserves stock")
	check(sim.transfer(lumber.id, "timber", -10, true) == 0, "Negative transfer rejected")
	sim.backpack.clear()
	var count = sim.buildings.size()
	check(sim.place("farm", Vector2i(8, 15), 0) != "", "Remote timber cannot pay construction")
	check(sim.buildings.size() == count, "Failed construction creates nothing")
	sim.backpack = {"timber":20}
	check(sim.place("farm", Vector2i(8, 15), 0) == "", "Valid placement succeeds")
	check(sim.backpack.timber == 8, "Cost paid exactly once from backpack")
	check(sim.place("farm", Vector2i(8, 15), 0) != "", "Overlapping placement rejected")
	check(sim.backpack.timber == 8, "Invalid placement spends nothing")
	sim.backpack = {"timber":600}
	check(sim.transfer(lumber.id, "timber", 10, true) == 0, "Full backpack rejects transfer")
	sim.backpack.timber = 599
	check(sim.transfer(lumber.id, "timber", 10, true) == 1, "Partial transfer honors stack capacity")
	check(sim.add_road(Vector2i(29, 14)) != "", "Water blocks roads")
	check(sim.placement_error("mine", Vector2i(12, 14), 0) != "", "Mine requires deposit")

func test_delivery_conservation() -> void:
	var sim = Simulation.new()
	var a = sim.create_building("barn", Vector2i(5, 5))
	var b = sim.create_building("barn", Vector2i(12, 5))
	a.inventory = {"timber":20}
	for x in range(6, 14):
		sim.roads[sim.tile_key(Vector2i(x, 8))] = true
	check(sim.add_route(a.id, b.id, "timber") == "", "Connected route accepted")
	check(sim.add_route(a.id, b.id, "timber") != "", "Duplicate route rejected")
	advance(sim, 3)
	check(a.inventory.timber < 20 and b.inventory.get("timber", 0) == 0, "Cargo travels instead of teleporting")
	check(total(sim, "timber") == 20, "In-flight cargo has exactly one owner")
	check(sim.erase_road(Vector2i(9, 8)) != "", "Cannot erase occupied route")
	# Fill destination while cart is in flight; it must retain its load.
	b.inventory = {"ore":600}
	advance(sim, 20)
	check(sim.routes[0].cargo == 4, "Full destination holds cargo on cart")
	check(total(sim, "timber") == 20, "Blocked delivery loses no cargo")
	b.inventory.clear()
	advance(sim, 40)
	check(int(b.inventory.get("timber", 0)) > 0, "Delivery resumes when room becomes available")
	check(total(sim, "timber") == 20, "Repeated trips conserve cargo")
	sim.routes[0].enabled = false
	advance(sim, 30)
	check(sim.remove_route(0) == "", "Paused route can be removed after return")
	check(sim.erase_road(Vector2i(9, 8)) == "", "Unoccupied road can be erased")
	check(sim.add_route(a.id, b.id, "timber") != "", "Disconnected route rejected")

func test_training_identity() -> void:
	var sim = Simulation.new()
	var hall = sim.create_building("hall", Vector2i(5, 5))
	var school = sim.create_building("sword_school", Vector2i(12, 5))
	school.inventory = {"sword":3, "food":6}
	for x in range(6, 14):
		sim.roads[sim.tile_key(Vector2i(x, 8))] = true
	var person = sim.recruit(hall.id)
	var identity = person.id
	check(sim.send_person(identity, school.id) == "", "Resident can follow a connected road to school")
	check(person.location == 0 and person.destination == school.id, "Walking resident is not in both buildings")
	advance(sim, 30)
	check(person.id == identity and person.skills.has("Sword"), "Training preserves identity and adds skill")
	check(person.gear.has("sword") and total(sim, "sword") == 3, "Sword becomes owned equipment")
	advance(sim, 30)
	check(person.skills.size() == 1 and school.inventory.sword == 2, "Already trained student isn't charged twice")
	var shield = sim.create_building("shield_school", Vector2i(19, 5))
	shield.inventory = {"shield":1, "food":2}
	for x in range(14, 21):
		sim.roads[sim.tile_key(Vector2i(x, 8))] = true
	sim.path_cache.clear()
	check(sim.send_person(identity, shield.id) == "", "Veteran can enter another school")
	advance(sim, 30)
	check(sim.unit_name(person) == "Man-at-Arms", "Sword plus Shield forms hybrid")
	check(sim.people.size() == 1 and person.gear.size() == 2, "Hybrid remains one person with two equipped items")
	check(sim.complete_mission() != "", "One hybrid does not count as three soldiers")
	for i in range(2):
		var extra = sim.recruit(hall.id)
		extra.skills.append("Sword")
	check(sim.complete_mission() == "" and sim.mission_complete, "Three distinct swordsmen unlock next school")

func test_save_recovery() -> void:
	var sim = Simulation.new()
	sim.new_game()
	advance(sim, 3)
	var path = "user://test_bannerworks.json"
	check(SaveStore.save_game(sim, path) == OK, "Save can be written")
	var copy = Simulation.new()
	check(SaveStore.load_game(copy, path) == "loaded", "Save loads")
	check(total(copy, "food") == total(sim, "food"), "Save roundtrip retains inventories and moving cargo")
	check(copy.people.size() == sim.people.size(), "Save retains citizens")
	check(copy.roads.size() == sim.roads.size(), "Save retains roads")
	check(SaveStore.save_game(sim, path) == OK, "Second save keeps a backup")
	var broken = FileAccess.open(path, FileAccess.WRITE)
	broken.store_string("truncated")
	broken.close()
	check(SaveStore.load_game(copy, path) == "backup", "Corrupt primary recovers previous good save")
	var invalid = sim.snapshot()
	invalid.version = 999
	check(not SaveStore.valid_state(invalid, sim.data), "Unknown save version rejected")
	for suffix in ["", ".bak", ".tmp"]:
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(path + suffix)

func test_refund_and_pause() -> void:
	var sim = Simulation.new()
	sim.new_game()
	var before = sim.elapsed
	sim.paused = true
	advance(sim, 60)
	check(sim.elapsed == before, "Paused simulation does not advance")
	sim.backpack = {"timber":600}
	var barn = sim.create_building("barn", Vector2i(9, 15))
	barn.inventory = {"sword":8}
	check(sim.dismantle(barn.id) == "", "Empty-of-people unconnected building dismantles")
	check(sim.crates.size() == 1, "Full backpack sends refund to pickup crate")
	check(total(sim, "sword") == 8, "Dismantle preserves stored equipment")
	sim.backpack.clear()
	check(sim.collect_crate(Vector2i(9, 15)) == 32, "Crate returns contents and full construction cost")
	check(sim.crates.is_empty(), "Empty pickup crate removed")
