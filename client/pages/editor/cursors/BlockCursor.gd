extends Node2D

signal level_event

var block_id: int = 0
var layers: Layers


func _ready():
	pass


func init(slider_menu, _layers) -> void:
	layers = _layers
	slider_menu.connect("control_event", _on_control_event)
	

func _on_control_event(event: Dictionary) -> void:
	print("BlockCursor::_on_control_event", event)
	if event.type == EditorEvents.SELECT_BLOCK:
		block_id = event.block_id
		Session.set_current_block_id(event.block_id)


func on_mouse_down():
	pass


func on_drag():
	var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
	var tilemap: TileMap = layer.get_node("TileMap")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = tilemap.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	var coords = tilemap.local_to_map(mouse_position)
	
	var atlas_coords = Helpers.to_atlas_coords(block_id)
	var existing_atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords != existing_atlas_coords:
		emit_signal("level_event", {
			"type": EditorEvents.SET_TILE,
			"layer_name": layers.get_target_layer(),
			"coords": {
				"x": coords.x,
				"y": coords.y
			},
			"block_id": block_id,
		})


func on_mouse_up():
	pass
