extends Node2D

signal level_event

var layers: Layers


func init(_layers: Layers) -> void:
	layers = _layers
	

func on_mouse_down():
	pass


func on_drag():
	erase_blocks()
	erase_lines()


func erase_lines():
	var radius: float = 20.0
	var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
	var line_holder: Node2D = layer.get_node("Lines")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = line_holder.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	for line in line_holder.get_children():
		var points = line.points
		for i in range(points.size() - 1):
			var p1: Vector2 = points[i] + line.position
			var p2: Vector2 = points[i + 1] + line.position
			
			# Check if the line segment p1-p2 intersects the circle
			if is_line_intersecting_circle(p1, p2, mouse_position, radius):
				line.queue_free()
				break # Break since the line should be removed


# Helper function to check if a line segment intersects a circle
func is_line_intersecting_circle(p1: Vector2, p2: Vector2, circle_center: Vector2, radius: float) -> bool:
	var segment_vector: Vector2 = p2 - p1
	var to_circle: Vector2 = circle_center - p1
	var segment_length: float = segment_vector.length()

	# Project the circle's center onto the line segment
	var projection_length: float = segment_vector.dot(to_circle) / segment_length
	var projection_point: Vector2 = p1 + (segment_vector.normalized() * projection_length)

	# Clamp the projection to lie on the segment
	var clamped_projection: Vector2 = projection_point.clamp(p1, p2)

	# Check the distance from the closest point on the segment to the circle's center
	var distance_to_circle: float = clamped_projection.distance_to(circle_center)

	return distance_to_circle <= radius


func erase_blocks():
	var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
	var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = tile_map_layer.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	var coords = tile_map_layer.local_to_map(mouse_position)
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	if atlas_coords != Vector2i(-1, -1):
		emit_signal("level_event", {
			"type": EditorEvents.SET_TILE,
			"layer_name": layers.get_target_layer(),
			"coords": {
				"x": coords.x,
				"y": coords.y
			},
			"block_id": 0
		})
		

func on_mouse_up():
	pass
