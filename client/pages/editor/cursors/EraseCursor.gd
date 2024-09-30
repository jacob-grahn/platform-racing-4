extends Node2D

signal level_event

@onready var layers = get_node("../../../Layers")


func on_mouse_down():
	pass


func on_drag():
	erase_blocks()
	erase_lines()


func erase_lines():
	var radius: int = 20
	var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
	var line_holder: Node2D = layer.get_node("Lines")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = line_holder.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	for line in line_holder.get_children():
		for point in line.points:
			var local_point: Vector2 = point + line.position
			if local_point.distance_to(mouse_position) < radius:
				line.queue_free()
				continue


func erase_blocks():
	var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
	var tilemap: TileMap = layer.get_node("TileMap")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = tilemap.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	var coords = tilemap.local_to_map(mouse_position)
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords != Vector2i(-1, -1):
		emit_signal("level_event", {
			"type": EditorEvents.SET_TILE,
			"layer_name": layers.get_target_layer(),
			"coords": coords,
			"block_id": 0
		})
		

func on_mouse_up():
	pass
