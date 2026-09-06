extends Button

var game
var item = ""
var building_id = 0
var from_backpack = false
var quantity = 0

func _get_drag_data(_position: Vector2):
	if quantity <= 0:
		return null
	var preview = Label.new()
	preview.text = "%d %s" % [mini(quantity, game.transfer_amount), game.sim.data.items[item].name]
	preview.add_theme_color_override("font_color", Color("f1d38d"))
	preview.add_theme_font_size_override("font_size", 18)
	set_drag_preview(preview)
	return {"item":item, "building_id":building_id, "from_backpack":from_backpack,
		"amount":mini(quantity, game.transfer_amount)}

func _can_drop_data(_position: Vector2, value) -> bool:
	return value is Dictionary and value.has("from_backpack") and value.from_backpack != from_backpack and value.building_id == building_id

func _drop_data(_position: Vector2, value) -> void:
	game.perform_transfer(value.item, value.amount, not value.from_backpack)
