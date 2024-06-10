extends Node2D

signal event

var block_id: int = 0


func _ready():
	var slider_menu = get_node("../../SliderMenu")
	slider_menu.connect("block_changed", _on_block_changed)


func _on_block_changed(new_block_id: int) -> void:
	block_id = new_block_id


func on_mouse_down():
	pass


func on_drag():
	var tilemap: TileMap = get_node("../../../Layers/Layer 1/TileMap")
	var mouse_position = tilemap.get_global_mouse_position()
	var coords = tilemap.local_to_map(tilemap.to_local(mouse_position))
	var atlas_coords = Helpers.to_atlas_coords(block_id)
	var existing_atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords != existing_atlas_coords:
		emit_signal("event", {
			"type": "set_tile",
			"coords": coords,
			"block_id": block_id,
		})


func on_mouse_up():
	pass
