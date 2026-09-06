extends PanelContainer

var game
var is_backpack = false
var building_id = 0

func _can_drop_data(_position: Vector2, value) -> bool:
	return value is Dictionary and value.has("from_backpack") and value.from_backpack != is_backpack and value.building_id == building_id

func _drop_data(_position: Vector2, value) -> void:
	game.perform_transfer(value.item, value.amount, is_backpack)
