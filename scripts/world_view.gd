extends Control
## Original vector placeholder art, drawn directly in Godot; no external assets.

const TILE = 40.0
var game
var center = Vector2(12, 10) * TILE
var zoom_level = 0.8
var touches: Dictionary = {}
var pointer_down = false
var moved = false
var start_pointer = Vector2.ZERO
var last_pointer = Vector2.ZERO
var road_stroke: Array = []
var ghost = Vector2i(10, 13)
var was_pinching = false
var mouse_pan = false

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func to_world(point: Vector2) -> Vector2:
	return (point - size * 0.5) / zoom_level + center

func to_screen(point: Vector2) -> Vector2:
	return (point - center) * zoom_level + size * 0.5

func tile_at(point: Vector2) -> Vector2i:
	return Vector2i((to_world(point) / TILE).floor())

func zoom_at(factor: float, point: Vector2) -> void:
	var before = to_world(point)
	zoom_level = clampf(zoom_level * factor, 0.45, 1.65)
	center += before - to_world(point)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device == -1:
		return # Touch is handled explicitly; emulated mouse remains enabled for UI drag/drop.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at(1.12, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at(1.0 / 1.12, event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_pan = event.pressed
			last_pointer = event.position
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				begin_pointer(event.position)
			else:
				end_pointer(event.position)
	elif event is InputEventMouseMotion:
		if mouse_pan:
			center -= event.relative / zoom_level
		elif pointer_down:
			move_pointer(event.position)
		elif game.mode == "build":
			ghost = tile_at(event.position)
		queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
			if touches.size() == 1:
				was_pinching = false
				begin_pointer(event.position)
			else:
				was_pinching = true
				road_stroke.clear()
		else:
			touches.erase(event.index)
			if touches.is_empty():
				if not was_pinching:
					end_pointer(event.position)
				pointer_down = false
				road_stroke.clear()
		queue_redraw()
	elif event is InputEventScreenDrag:
		if not touches.has(event.index):
			return
		if touches.size() >= 2:
			var old_points = touches.values()
			var old_distance = old_points[0].distance_to(old_points[1])
			var old_mid = (old_points[0] + old_points[1]) * 0.5
			touches[event.index] = event.position
			var points = touches.values()
			var new_mid = (points[0] + points[1]) * 0.5
			if old_distance > 5.0:
				zoom_at(points[0].distance_to(points[1]) / old_distance, old_mid)
			center -= (new_mid - old_mid) / zoom_level
		else:
			touches[event.index] = event.position
			if not was_pinching:
				move_pointer(event.position)
		queue_redraw()

func begin_pointer(point: Vector2) -> void:
	pointer_down = true
	moved = false
	start_pointer = point
	last_pointer = point
	if game.mode == "road":
		road_stroke = [tile_at(point)]
	if game.mode == "build":
		ghost = tile_at(point)
	queue_redraw()

func move_pointer(point: Vector2) -> void:
	if point.distance_to(start_pointer) > 8:
		moved = true
	if game.mode == "road":
		if road_stroke.is_empty():
			road_stroke.append(tile_at(point))
		var here: Vector2i = road_stroke[-1]
		var target = tile_at(point)
		while here.x != target.x:
			here.x += 1 if target.x > here.x else -1
			if not road_stroke.has(here):
				road_stroke.append(here)
		while here.y != target.y:
			here.y += 1 if target.y > here.y else -1
			if not road_stroke.has(here):
				road_stroke.append(here)
	elif game.mode == "build":
		ghost = tile_at(point)
	else:
		center -= (point - last_pointer) / zoom_level
	last_pointer = point
	queue_redraw()

func end_pointer(point: Vector2) -> void:
	if not pointer_down:
		return
	pointer_down = false
	if game.mode == "road":
		game.paint_roads(road_stroke)
		road_stroke.clear()
	elif game.mode == "build":
		ghost = tile_at(point)
		game.refresh_build_hint()
	elif not moved:
		game.map_tap(tile_at(point))
	queue_redraw()

func _draw() -> void:
	if game == null:
		return
	var sim = game.sim
	draw_rect(Rect2(Vector2.ZERO, size), Color("223e36"))
	var low = Vector2i((to_world(Vector2.ZERO) / TILE).floor()) - Vector2i.ONE
	var high = Vector2i((to_world(size) / TILE).ceil()) + Vector2i.ONE
	var scale_tile = TILE * zoom_level
	for x in range(maxi(0, low.x), mini(sim.MAP_SIZE, high.x)):
		for y in range(maxi(0, low.y), mini(sim.MAP_SIZE, high.y)):
			var tile = Vector2i(x, y)
			var pos = to_screen(Vector2(tile) * TILE)
			var type = sim.terrain(tile)
			var noise = float((x * 13 + y * 7) % 5) * 0.008
			var ground = Color(0.32 + noise, 0.45 + noise, 0.32 + noise)
			if type == "water":
				ground = Color("427d90")
			draw_rect(Rect2(pos, Vector2.ONE * (scale_tile + 1)), ground)
			draw_rect(Rect2(pos, Vector2.ONE * scale_tile), Color(0.85, 0.89, 0.7, 0.055), false, 1)
			if type == "water":
				draw_line(pos + Vector2(7, 18) * zoom_level, pos + Vector2(25, 18) * zoom_level, Color("609ba9"), zoom_level)
			elif type == "forest":
				draw_tree(pos, zoom_level)
			elif type == "iron":
				for i in range(3):
					draw_circle(pos + Vector2(9 + i * 9, 14 + i % 2 * 8) * zoom_level, (7 + i) * zoom_level, Color("8e9c9c"))
			elif (x * 3 + y * 7) % 17 == 0:
				draw_circle(pos + Vector2(14, 22) * zoom_level, 1.5 * zoom_level, Color("c8c995"))
	for key in sim.roads:
		var p = to_screen(Vector2(sim.key_tile(key)) * TILE)
		var middle = p + Vector2.ONE * scale_tile * 0.5
		draw_rect(Rect2(p + Vector2.ONE * scale_tile * 0.13, Vector2.ONE * scale_tile * 0.74), Color("ad9d7b"))
		for direction in sim.DIRECTIONS:
			if sim.roads.has(sim.tile_key(sim.key_tile(key) + direction)):
				draw_line(middle, middle + Vector2(direction) * scale_tile * 0.53, Color("ad9d7b"), scale_tile * 0.72)
		draw_line(middle + Vector2(-3, 0) * zoom_level, middle + Vector2(3, 0) * zoom_level, Color("dbccaa"), zoom_level)
	for building in sim.buildings:
		draw_building(building)
	for route in sim.routes:
		if route.path.is_empty():
			continue
		if game.show_flows:
			var points = PackedVector2Array()
			for key in route.path:
				points.append(to_screen((Vector2(sim.key_tile(key)) + Vector2.ONE * 0.5) * TILE))
			if points.size() > 1:
				draw_polyline(points, Color(0.98, 0.76, 0.3, 0.55), 2)
		var distance = float(route.position)
		if not sim.paused and game.focused and route.wait <= 0.0:
			if route.returning:
				distance = maxf(0, distance - game.accumulator)
			elif route.cargo > 0:
				distance = minf(float(route.path.size() - 1), distance + game.accumulator)
		var cart = path_point(route.path, distance)
		draw_circle(cart + Vector2(-4, 4) * zoom_level, 2.5 * zoom_level, Color("26363d"))
		draw_circle(cart + Vector2(4, 4) * zoom_level, 2.5 * zoom_level, Color("26363d"))
		draw_rect(Rect2(cart - Vector2(6, 5) * zoom_level, Vector2(12, 9) * zoom_level), Color("684c38"))
		if route.cargo > 0:
			draw_rect(Rect2(cart - Vector2(4, 4) * zoom_level, Vector2(8, 6) * zoom_level), Color(sim.data.items[route.item].color))
	for person in sim.people:
		if person.path.is_empty():
			continue
		var distance = float(person.position)
		if not sim.paused and game.focused:
			distance = minf(float(person.path.size() - 1), distance + game.accumulator * 1.4)
		var position_on_road = path_point(person.path, distance) + Vector2(0, -5) * zoom_level
		draw_circle(position_on_road, 4.0 * zoom_level, Color("57d4bf"))
		draw_circle(position_on_road + Vector2(0, -4) * zoom_level, 2.5 * zoom_level, Color("f0d8b5"))
	for crate in sim.crates:
		var p = to_screen((Vector2(crate.x, crate.y) + Vector2.ONE * 0.5) * TILE)
		draw_rect(Rect2(p - Vector2.ONE * 8, Vector2.ONE * 16), Color("e1b873"))
		draw_line(p - Vector2.ONE * 7, p + Vector2.ONE * 7, Color("806043"), 2)
	for tile in road_stroke:
		draw_rect(Rect2(to_screen(Vector2(tile) * TILE), Vector2.ONE * scale_tile), Color(0.9, 0.78, 0.4, 0.5))
	if game.mode == "build":
		var n = int(sim.data.buildings[game.build_kind].size)
		var valid = sim.placement_error(game.build_kind, ghost, game.rotation).is_empty() and sim.can_pay(sim.backpack, sim.data.buildings[game.build_kind].cost)
		var color = Color("6fe5bd") if valid else Color("ee8c79")
		var rect = Rect2(to_screen(Vector2(ghost) * TILE), Vector2.ONE * n * scale_tile)
		draw_rect(rect, Color(color, 0.3))
		draw_rect(rect.grow(-1), color, false, 2)
		var probe = {"kind":game.build_kind, "x":ghost.x, "y":ghost.y, "rotation":game.rotation}
		var gate = to_screen((Vector2(sim.port(probe)) + Vector2.ONE * 0.5) * TILE)
		draw_circle(gate, 5, color)

func path_point(path: Array, distance: float) -> Vector2:
	var a = mini(int(floor(distance)), path.size() - 1)
	var b = mini(a + 1, path.size() - 1)
	var start = Vector2(game.sim.key_tile(path[maxi(0, a)])) + Vector2.ONE * 0.5
	var finish = Vector2(game.sim.key_tile(path[b])) + Vector2.ONE * 0.5
	return to_screen(start.lerp(finish, clampf(distance - a, 0, 1)) * TILE)

func draw_tree(pos: Vector2, z: float) -> void:
	draw_circle(pos + Vector2(23, 26) * z, 11 * z, Color(0.09, 0.2, 0.17, 0.35))
	draw_rect(Rect2(pos + Vector2(18, 20) * z, Vector2(4, 12) * z), Color("715d42"))
	draw_circle(pos + Vector2(20, 15) * z, 13 * z, Color("2e5a48"))
	draw_circle(pos + Vector2(17, 11) * z, 9 * z, Color("427352"))

func draw_building(building: Dictionary) -> void:
	var spec = game.sim.definition(building)
	var z = zoom_level
	var p = to_screen(Vector2(building.x, building.y) * TILE)
	var extent = float(spec.size) * TILE * z
	var rect = Rect2(p + Vector2.ONE * 3 * z, Vector2.ONE * (extent - 6 * z))
	draw_rect(Rect2(rect.position + Vector2(3, 5) * z, rect.size), Color(0.08, 0.16, 0.14, 0.32))
	draw_rect(rect, Color("b7ab87"))
	draw_rect(rect.grow(-4 * z), Color("e0cba4"))
	if building.kind == "farm":
		draw_rect(rect.grow(-6 * z), Color("766842"))
		for i in range(5):
			var y = rect.position.y + (12 + i * 11) * z
			draw_line(Vector2(rect.position.x + 8 * z, y), Vector2(rect.end.x - 8 * z, y), Color("c9b75d"), 5 * z)
	elif building.kind == "mine":
		draw_circle(rect.get_center(), extent * 0.36, Color("87908c"))
		draw_rect(Rect2(rect.get_center() - Vector2(17, 8) * z, Vector2(34, 27) * z), Color("364640"))
		draw_line(rect.get_center() + Vector2(-21, -10) * z, rect.get_center() + Vector2(21, -10) * z, Color("b79a70"), 7 * z)
	else:
		var roof = rect.grow(-7 * z)
		draw_rect(roof, Color(spec.color))
		draw_rect(Rect2(roof.position, Vector2(roof.size.x * 0.5, roof.size.y)), Color(spec.color).lightened(0.13))
		draw_line(roof.position + Vector2(roof.size.x / 2, 0), roof.position + Vector2(roof.size.x / 2, roof.size.y), Color("d9b785"), 3 * z)
		for i in range(1, 4):
			var y = roof.position.y + roof.size.y * float(i) / 4
			draw_line(Vector2(roof.position.x, y), Vector2(roof.end.x, y), Color(0.1, 0.19, 0.23, 0.18), z)
		if building.kind in ["smithy", "kiln"]:
			draw_rect(Rect2(roof.position + Vector2(7, 4) * z, Vector2(14, 18) * z), Color("555953"))
			draw_rect(Rect2(roof.position + Vector2(10, 7) * z, Vector2(8, 6) * z), Color("f7ad65"))
		if building.kind.ends_with("school") or building.kind == "hall":
			var flag = roof.position + Vector2(roof.size.x - 11 * z, 3 * z)
			draw_line(flag, flag + Vector2(0, -20) * z, Color("ead6a8"), 2 * z)
			draw_rect(Rect2(flag + Vector2(0, -20) * z, Vector2(16, 10) * z), Color("56c9b4"))
	var gate = to_screen((Vector2(game.sim.port(building)) + Vector2.ONE * 0.5) * TILE)
	draw_line(rect.get_center(), gate, Color(0.94, 0.8, 0.48, 0.55), 3 * z)
	draw_rect(Rect2(gate - Vector2.ONE * 4 * z, Vector2.ONE * 8 * z), Color("f5d895"))
	if building.id == game.selected_id:
		draw_rect(rect.grow(2), Color("79e3c5"), false, 2)
	var font = ThemeDB.fallback_font
	var label_size = 10 if z < 0.9 else 12
	var title = str(spec.name)
	var width = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size).x
	var origin = Vector2(rect.get_center().x - width / 2, rect.end.y - 3 * z)
	draw_rect(Rect2(origin + Vector2(-3, -label_size), Vector2(width + 6, label_size + 4)), Color(0.07, 0.14, 0.18, 0.87))
	draw_string(font, origin, title, HORIZONTAL_ALIGNMENT_LEFT, -1, label_size, Color("f0ead5"))
