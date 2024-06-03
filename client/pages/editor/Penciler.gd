extends Node2D

var layers: Node2D


func _ready():
	layers = get_parent().get_node("Layers")
	get_parent().get_node("EditorEvents").connect("do_event", _on_do_event)


func _on_do_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_TILE:
		var tilemap: TileMap = layers.get_node("Layer 1/TileMap")
		tilemap.set_cell(0, event.coords, 0, Helpers.to_atlas_coords(event.block_id))
