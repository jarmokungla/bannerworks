extends Control

const Simulation = preload("res://scripts/simulation.gd")
const SaveStore = preload("res://scripts/save_store.gd")
const WorldView = preload("res://scripts/world_view.gd")
const StackButton = preload("res://scripts/stack_button.gd")
const InventoryPanel = preload("res://scripts/inventory_panel.gd")

var sim = Simulation.new()
var world
var mode = "inspect"
var build_kind = "farm"
var build_rotation = 0
var selected_id = 0
var transfer_amount = 10
var route_source = 0
var route_item = "food"
var person_to_send = 0
var show_flows = true
var accumulator = 0.0
var ui_clock = 0.0
var save_clock = 0.0
var focused = true
var saving_enabled = true
var panel_kind = ""
var content: VBoxContainer
var sheet: PanelContainer
var scroll: ScrollContainer
var message_label: Label
var population_label: Label
var status_label: Label
var bag_button: Button
var pause_button: Button
var inventory_buttons: Array = []
var build_hint: Label
var save_status = ""
var ui_queued = false

func _ready() -> void:
	Engine.max_fps = 60
	get_tree().auto_accept_quit = false
	make_theme()
	var loaded = SaveStore.load_game(sim)
	if loaded in ["missing", "invalid"]:
		sim.new_game()
		# Do not overwrite an unrecognized save. The player must explicitly choose New town.
		saving_enabled = loaded != "invalid"
	make_ui()
	if loaded == "invalid":
		notify("Save unreadable; using a temporary town. New town explicitly replaces it.")
	elif loaded == "backup":
		notify("Recovered your previous save.")
	else:
		notify("Tap buildings to inspect. Drag the map; pinch to zoom.")
	if "--smoke-test" in OS.get_cmdline_user_args():
		await get_tree().create_timer(2.0).timeout
		get_tree().quit()

func make_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 14
	for type in ["Label", "Button", "OptionButton", "CheckButton"]:
		theme.set_color("font_color", type, Color("e9e8d9"))
	theme.set_color("font_color_disabled", "Button", Color("788889"))
	for type in ["Button", "OptionButton"]:
		theme.set_stylebox("normal", type, style(Color("23414b"), Color("3d5b62"), 8))
		theme.set_stylebox("hover", type, style(Color("2d5560"), Color("67b4ac"), 8))
		theme.set_stylebox("pressed", type, style(Color("276e66"), Color("78d3bd"), 8))
		theme.set_stylebox("disabled", type, style(Color("263738"), Color("344849"), 8))
		theme.set_stylebox("focus", type, style(Color(0, 0, 0, 0), Color("e5c581"), 8))
	theme.set_stylebox("panel", "PanelContainer", style(Color("132d38"), Color("35545a"), 12))
	theme.set_constant("separation", "VBoxContainer", 8)
	theme.set_constant("separation", "HBoxContainer", 6)

func style(background: Color, border: Color, radius: int) -> StyleBoxFlat:
	var box = StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

func make_ui() -> void:
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var safe_top = 14
	var safe_bottom = 14
	if OS.has_feature("ios"):
		var safe = DisplayServer.get_display_safe_area()
		var physical = DisplayServer.window_get_size()
		if physical.y > 0:
			var ratio = size.y / float(physical.y)
			safe_top = maxi(safe_top, int(safe.position.y * ratio))
			safe_bottom = maxi(safe_bottom, int((physical.y - safe.end.y) * ratio))
	margin.add_theme_constant_override("margin_top", safe_top)
	margin.add_theme_constant_override("margin_bottom", safe_bottom)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	var layout = VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	margin.add_child(layout)
	var header = HBoxContainer.new()
	layout.add_child(header)
	var heading = VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(heading)
	var title = label("BANNERWORKS", heading, 22)
	title.add_theme_color_override("font_color", Color("e6cb8a"))
	population_label = label("", heading, 12)
	bag_button = button("Bag", header, _open_bag)
	pause_button = button("II", header, _toggle_pause)
	pause_button.custom_minimum_size.x = 44
	world = WorldView.new()
	world.game = self
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	world.custom_minimum_size.y = 120
	layout.add_child(world)
	message_label = label("", layout, 13)
	message_label.custom_minimum_size.y = 38
	message_label.add_theme_color_override("font_color", Color("c8d4c7"))
	sheet = PanelContainer.new()
	layout.add_child(sheet)
	scroll = ScrollContainer.new()
	scroll.custom_minimum_size.y = 315
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	sheet.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	sheet.hide()
	var toolbar = HBoxContainer.new()
	layout.add_child(toolbar)
	button("Build", toolbar, _open_build).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Roads", toolbar, _open_roads).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Army", toolbar, _open_army).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Menu", toolbar, _open_menu).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	refresh_live_ui()

func label(text: String, parent: Node, font_size: int = 14) -> Label:
	var control = Label.new()
	control.text = text
	control.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	control.add_theme_font_size_override("font_size", font_size)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(control)
	return control

func button(text: String, parent: Node, action: Callable) -> Button:
	var control = Button.new()
	control.text = text
	control.custom_minimum_size.y = 44
	control.pressed.connect(action)
	parent.add_child(control)
	return control

func notify(text: String) -> void:
	message_label.text = text

func queue_ui() -> void:
	if not ui_queued:
		ui_queued = true
		refresh_panel.call_deferred()

func show_panel(kind: String) -> void:
	panel_kind = kind
	queue_ui()

func clear_content() -> void:
	inventory_buttons.clear()
	status_label = null
	build_hint = null
	for child in content.get_children():
		content.remove_child(child)
		child.queue_free()

func refresh_panel() -> void:
	ui_queued = false
	clear_content()
	sheet.visible = panel_kind != ""
	if panel_kind == "":
		return
	var top = HBoxContainer.new()
	content.add_child(top)
	var title = label(panel_title(), top, 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Close", top, _close_panel)
	match panel_kind:
		"build": build_catalog()
		"placing": build_placement()
		"inspect": build_inspector()
		"roads": build_roads()
		"route": build_route_picker()
		"army": build_army()
		"bag": build_backpack()
		"menu": build_menu()
	refresh_live_ui()

func panel_title() -> String:
	match panel_kind:
		"build": return "Build your settlement"
		"placing": return sim.data.buildings[build_kind].name
		"inspect":
			var b = sim.get_building(selected_id)
			return sim.definition(b).name if not b.is_empty() else "Building"
		"roads": return "Road network"
		"route": return "Create a delivery"
		"army": return "Border Patrol"
		"bag": return "Your backpack"
		_: return "Town menu"

func build_catalog() -> void:
	label("Construction uses materials in your backpack. Gold squares mark road gates.", content)
	for kind in sim.data.buildings:
		if kind == "hall":
			continue
		var spec = sim.data.buildings[kind]
		var locked = kind == "shield_school" and not sim.mission_complete
		var text = "%s · %s" % [spec.name, format_items(spec.cost)]
		if locked:
			text = "Shield School · unlock with Border Patrol"
		var control = button(text, content, _choose_build.bind(kind))
		control.add_theme_font_size_override("font_size", 13)
		control.disabled = locked

func build_placement() -> void:
	label("Drag the ghost onto clear tiles. Pinch to move the map. Rotate the gold gate toward your road.", content)
	build_hint = label("", content)
	var row = HBoxContainer.new()
	content.add_child(row)
	button("Rotate", row, _rotate).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Place building", row, _place).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button("Choose another building", content, _open_build)
	refresh_build_hint()

func refresh_build_hint() -> void:
	if not is_instance_valid(build_hint):
		return
	var cost = sim.data.buildings[build_kind].cost
	var lines = PackedStringArray(["In backpack / Needed"])
	for item in cost:
		lines.append("%s: %d / %d" % [sim.data.items[item].name, sim.backpack.get(item, 0), cost[item]])
	var error = sim.placement_error(build_kind, world.ghost, build_rotation)
	if not error.is_empty():
		lines.append(error)
	build_hint.text = "\n".join(lines)

func build_inspector() -> void:
	var building = sim.get_building(selected_id)
	if building.is_empty():
		return
	var spec = sim.definition(building)
	status_label = label("", content)
	label(spec.note, content, 12)
	var quantities = HBoxContainer.new()
	content.add_child(quantities)
	label("Transfer", quantities)
	for amount in [1, 10, 50]:
		var control = button(str(amount), quantities, _set_amount.bind(amount))
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if amount == transfer_amount:
			control.add_theme_color_override("font_color", Color("77dfbf"))
	label("Drag between columns, or tap a stack to transfer.", content, 12)
	var inventories = HBoxContainer.new()
	content.add_child(inventories)
	make_inventory(inventories, false, building)
	make_inventory(inventories, true, building)
	if spec.get("recipes", []).size() > 1:
		label("Recipe (one at a time)", content, 12)
		var picker = OptionButton.new()
		picker.custom_minimum_size.y = 44
		content.add_child(picker)
		for recipe in spec.recipes:
			picker.add_item(sim.data.items[recipe].name)
		picker.select(spec.recipes.find(building.recipe))
		picker.item_selected.connect(_recipe_selected.bind(building.id))
	if spec.has("skill"):
		button("Enroll next eligible resident", content, _enroll)
	button("Create delivery from here", content, _start_route)
	button("Resume production" if not building.enabled else "Pause production", content, _toggle_building)
	button("Dismantle (refund materials)", content, _dismantle)

func make_inventory(parent: Node, is_backpack: bool, building: Dictionary) -> void:
	var panel = InventoryPanel.new()
	panel.game = self
	panel.is_backpack = is_backpack
	panel.building_id = building.id
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	var column = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(column)
	label("Backpack" if is_backpack else "Building", column, 13)
	# Fixed rows remain stable during simulation updates and native drag gestures.
	for item in sim.data.items:
		var stack = StackButton.new()
		stack.game = self
		stack.item = item
		stack.building_id = building.id
		stack.from_backpack = is_backpack
		stack.custom_minimum_size.y = 44
		stack.add_theme_font_size_override("font_size", 12)
		stack.add_theme_color_override("font_color", Color(sim.data.items[item].color))
		stack.pressed.connect(_tap_stack.bind(item, not is_backpack))
		column.add_child(stack)
		inventory_buttons.append(stack)

func build_roads() -> void:
	label("Draw a road with one finger. Each new tile costs 1 timber from your backpack. Use two fingers to pan and zoom.", content)
	button("Draw roads", content, _draw_roads)
	button("Erase a road tile", content, _erase_roads)
	button("Hide flows" if show_flows else "Show flows", content, _toggle_flows)
	label("Deliveries · carts carry 4 items, 1 tile/sec", content, 13)
	if sim.routes.is_empty():
		label("Select a building and choose Create delivery from here.", content)
	for i in range(sim.routes.size()):
		var route = sim.routes[i]
		var source = sim.get_building(route.source)
		var target = sim.get_building(route.target)
		label("%s → %s\n%s · %s" % [sim.definition(source).name, sim.definition(target).name, sim.data.items[route.item].name, route.status], content, 13)
		var row = HBoxContainer.new()
		content.add_child(row)
		button("Pause" if route.enabled else "Resume", row, _toggle_route.bind(i)).size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button("Remove", row, _remove_route.bind(i)).size_flags_horizontal = Control.SIZE_EXPAND_FILL

func build_route_picker() -> void:
	label("Choose cargo, then tap the destination building on the map. Both gold gates must connect to the same road network.", content)
	var picker = OptionButton.new()
	picker.custom_minimum_size.y = 44
	content.add_child(picker)
	var items = sim.data.items.keys()
	for item in items:
		picker.add_item(sim.data.items[item].name)
	picker.select(items.find(route_item))
	picker.item_selected.connect(_cargo_selected)
	label("One cart is assigned to each route. Its empty return journey also takes time.", content, 12)

func build_army() -> void:
	var trained = 0
	for person in sim.people:
		if person.skills.has("Sword"):
			trained += 1
	label("Train 3 swordsmen · %d/3\nReward: Shield School and the Man-at-Arms combination." % trained, content)
	button("Patrol completed" if sim.mission_complete else "Complete Border Patrol", content, _mission).disabled = sim.mission_complete
	label("Residents retain their skills when sent to another school.", content, 12)
	for person in sim.people:
		var location = sim.get_building(person.location)
		var where = sim.definition(location).name if not location.is_empty() else "Walking"
		label("%s · %s\n%s" % [person.name, sim.unit_name(person), where], content, 13)
		button("Send to a building…", content, _choose_person.bind(person.id)).disabled = not person.path.is_empty()

func build_backpack() -> void:
	label("%d / 12 slots used. Materials here pay for construction. Open a building to transfer its stock." % sim.slots_used(sim.backpack), content)
	for item in sim.data.items:
		label("%s: %d" % [sim.data.items[item].name, sim.backpack.get(item, 0)], content)
	button("Gather 5 timber by hand", content, _gather)
	label("Hand gathering is a recovery tool while the prototype's worker system is being developed.", content, 12)

func build_menu() -> void:
	label("Prototype 0.1 · Godot\nOffline simulation pauses when the app is inactive. Saves every 30 seconds and on app pause.", content)
	button("Save now", content, _save_now)
	button("Center on Town Hall", content, _center_town)
	button("How to play", content, _help)
	button("New town…", content, _confirm_reset)
	label("Early development build: worker professions, archery, combat, audio and final artwork are still to come.", content, 12)

func format_items(items: Dictionary) -> String:
	var parts = PackedStringArray()
	for item in items:
		parts.append("%d %s" % [items[item], sim.data.items[item].name.to_lower()])
	return ", ".join(parts)

func refresh_live_ui() -> void:
	population_label.text = "%d / 12 residents  ·  %s" % [sim.people.size(), "Paused" if sim.paused else "Frontier town"]
	bag_button.text = "Bag %d/12" % sim.slots_used(sim.backpack)
	pause_button.text = ">" if sim.paused else "II"
	var building = sim.get_building(selected_id)
	if is_instance_valid(status_label) and not building.is_empty():
		status_label.text = "%s · %.0fs\nStorage: %d / %d slots" % [building.status, building.progress, sim.slots_used(building.inventory), sim.definition(building).slots]
	for stack in inventory_buttons:
		if not is_instance_valid(stack) or building.is_empty():
			continue
		var inventory = sim.backpack if stack.from_backpack else building.inventory
		stack.quantity = int(inventory.get(stack.item, 0))
		stack.text = "%s  %d" % [sim.data.items[stack.item].name, stack.quantity]
	refresh_build_hint()

func _process(delta: float) -> void:
	if not focused:
		return
	# Bounded work after interruptions; no accidental offline catch-up.
	accumulator += minf(delta, 0.25)
	while accumulator >= Simulation.STEP:
		sim.tick(Simulation.STEP)
		accumulator -= Simulation.STEP
	ui_clock += delta
	save_clock += delta
	if ui_clock >= 0.2:
		ui_clock = 0.0
		refresh_live_ui()
	world.queue_redraw()
	if save_clock >= 30.0:
		save_clock = 0.0
		write_save(false)

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		focused = false
		if is_instance_valid(message_label):
			write_save(false)
	elif what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN]:
		focused = true
		accumulator = 0.0
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		write_save(false)
		get_tree().quit()

func write_save(show_message: bool) -> void:
	if not saving_enabled:
		if show_message:
			notify("Existing save unreadable. Choose New town to explicitly replace it.")
		return
	var result = SaveStore.save_game(sim)
	if result != OK:
		notify("Could not save (%s). Keep the game open and try again." % error_string(result))
	elif show_message:
		notify("Town saved on this device.")

func map_tap(tile: Vector2i) -> void:
	if mode == "erase":
		var error = sim.erase_road(tile)
		notify("Road removed; timber refunded." if error == "" else error)
		return
	var building = sim.building_at(tile)
	if building.is_empty():
		var collected = sim.collect_crate(tile)
		if collected > 0:
			notify("Collected %d items into your backpack." % collected)
		return
	if mode == "route":
		var error = sim.add_route(route_source, building.id, route_item)
		if error != "":
			notify(error)
			return
		notify("Delivery created. Watch its cart carry the materials.")
		mode = "inspect"
		show_panel("roads")
	elif mode == "person":
		var error = sim.send_person(person_to_send, building.id)
		notify("Resident is on the way." if error == "" else error)
		if error == "":
			mode = "inspect"
			show_panel("army")
	else:
		selected_id = building.id
		world.center = (Vector2(building.x, building.y) + Vector2.ONE * float(sim.definition(building).size) / 2) * world.TILE
		show_panel("inspect")

func paint_roads(tiles: Array) -> void:
	var unique = []
	for tile in tiles:
		if not sim.roads.has(sim.tile_key(tile)) and not unique.has(tile):
			unique.append(tile)
	for tile in unique:
		if sim.terrain(tile) in ["water", "forest", "edge"] or not sim.building_at(tile).is_empty():
			notify("Road cancelled: every tile must be clear ground.")
			return
	if not sim.can_pay(sim.backpack, {"timber":unique.size()}):
		notify("Road cancelled: need %d timber in your backpack." % unique.size())
		return
	for tile in unique:
		sim.add_road(tile)
	notify("Built %d road tiles. Select a source building to configure a delivery." % unique.size())
	refresh_live_ui()

func perform_transfer(item: String, amount: int, to_backpack: bool) -> void:
	var moved = sim.transfer(selected_id, item, amount, to_backpack)
	notify("Moved %d %s %s." % [moved, sim.data.items[item].name.to_lower(), "to backpack" if to_backpack else "to building"])
	refresh_live_ui()

func _tap_stack(item: String, to_backpack: bool) -> void:
	perform_transfer(item, transfer_amount, to_backpack)

func _set_amount(amount: int) -> void:
	transfer_amount = amount
	queue_ui()

func _recipe_selected(index: int, id: int) -> void:
	var building = sim.get_building(id)
	sim.set_recipe(id, sim.definition(building).recipes[index])
	refresh_live_ui()

func _enroll() -> void:
	var school = sim.get_building(selected_id)
	var skill = sim.definition(school).skill
	for person in sim.people:
		if person.location == school.id and not person.skills.has(skill):
			notify("An eligible resident is already here; supply equipment and rations.")
			return
	for person in sim.people:
		if person.path.is_empty() and person.location != school.id and not person.skills.has(skill):
			var result = sim.send_person(person.id, school.id)
			if result == "":
				notify("%s is walking to school." % person.name)
				return
	notify("No eligible resident has a connected road to this school.")

func _toggle_building() -> void:
	var building = sim.get_building(selected_id)
	building.enabled = not building.enabled
	queue_ui()

func _dismantle() -> void:
	var error = sim.dismantle(selected_id)
	if error != "":
		notify(error)
	else:
		selected_id = 0
		show_panel("")
		notify("Building dismantled. Overflow is in a pickup crate on its old tile.")

func _toggle_route(index: int) -> void:
	sim.routes[index].enabled = not sim.routes[index].enabled
	queue_ui()

func _remove_route(index: int) -> void:
	var error = sim.remove_route(index)
	notify("Route removed." if error == "" else error)
	queue_ui()

func _choose_person(id: int) -> void:
	person_to_send = id
	mode = "person"
	show_panel("")
	notify("Tap the destination building for this resident.")

func _mission() -> void:
	var error = sim.complete_mission()
	notify("Border Patrol complete! Shield School unlocked; soldiers stay in your town." if error == "" else error)
	queue_ui()

func _start_route() -> void:
	route_source = selected_id
	mode = "route"
	show_panel("route")

func _cargo_selected(index: int) -> void:
	route_item = sim.data.items.keys()[index]

func _open_build() -> void:
	mode = "inspect"
	show_panel("build")

func _choose_build(kind: String) -> void:
	build_kind = kind
	mode = "build"
	world.ghost = Vector2i((world.center / world.TILE).floor())
	show_panel("placing")
	notify("Position your building, then tap Place building.")

func _rotate() -> void:
	build_rotation = (build_rotation + 1) % 4
	refresh_build_hint()
	world.queue_redraw()

func _place() -> void:
	var error = sim.place(build_kind, world.ghost, build_rotation)
	notify("Building placed. Connect its gold gate by road." if error == "" else error)
	refresh_live_ui()
	world.queue_redraw()

func _open_roads() -> void:
	mode = "inspect"
	show_panel("roads")

func _draw_roads() -> void:
	mode = "road"
	show_panel("")
	notify("Draw roads · 1 timber/tile. Tap Roads or another tool to stop.")

func _erase_roads() -> void:
	mode = "erase"
	show_panel("")
	notify("Tap a road tile to remove it. Timber is refunded.")

func _toggle_flows() -> void:
	show_flows = not show_flows
	queue_ui()

func _open_army() -> void:
	mode = "inspect"
	show_panel("army")

func _open_bag() -> void:
	mode = "inspect"
	show_panel("bag")

func _open_menu() -> void:
	mode = "inspect"
	show_panel("menu")

func _close_panel() -> void:
	mode = "inspect"
	show_panel("")

func _toggle_pause() -> void:
	sim.paused = not sim.paused
	refresh_live_ui()

func _gather() -> void:
	var accepted = sim.add_items(sim.backpack, "timber", 5, sim.BAG_SLOTS)
	notify("Gathered %d timber." % accepted)
	queue_ui()

func _save_now() -> void:
	write_save(true)

func _center_town() -> void:
	world.center = Vector2(12, 10) * world.TILE
	world.zoom_level = 0.8
	_close_panel()

func _help() -> void:
	var dialog = AcceptDialog.new()
	dialog.title = "Your first production line"
	dialog.dialog_text = "1. Tap Lumber Camp; transfer timber into your bag.\n2. Place a Kiln and two Smithies.\n3. Draw roads connecting their gold gates.\n4. Create timber→Kiln, ore + charcoal→Smithy deliveries.\n5. Set the other Smithy to Swords; deliver bars + timber.\n6. Place Sword School; deliver swords + rations.\n7. Enroll residents; train 3 swordsmen for Border Patrol.\n\nDrag map to pan; pinch or mouse wheel to zoom.\nRight mouse drag pans in every tool.\nEvery building stores its own items. No remote construction."
	dialog.dialog_autowrap = true
	add_child(dialog)
	dialog.popup_centered(Vector2i(360, 470))
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)

func _confirm_reset() -> void:
	var dialog = ConfirmationDialog.new()
	dialog.title = "Replace this town?"
	dialog.dialog_text = "This replaces the current town with the starting settlement."
	dialog.dialog_autowrap = true
	add_child(dialog)
	dialog.confirmed.connect(_reset_town)
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.popup_centered(Vector2i(340, 160))

func _reset_town() -> void:
	sim.new_game()
	saving_enabled = true
	selected_id = 0
	_center_town()
	write_save(true)
