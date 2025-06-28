extends Node2D

signal level_event

var block_id: int = 0
var layers: Layers


func _ready():
	pass


func init(slider_menu, _layers) -> void:
	print("BlockCursor::init")
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
	var tilemap: TileMapLayer = layer.get_node("TileMap")
	var camera: Camera2D = get_viewport().get_camera_2d()
	# Get screen position of mouseAdd commentMore actions
	var viewport_mouse_pos = get_viewport().get_mouse_position()
	
	# Convert to world position taking into account camera position, zoom, and layer scale
	var world_pos = (viewport_mouse_pos - get_viewport_rect().size / 2) / camera.zoom.x
	world_pos += camera.position
	
	# Adjust for layer depth scaling
	world_pos *= layer.follow_viewport_scale
	
	# Account for tilemap rotation
	var rotated_pos = world_pos
	if tilemap.rotation != 0:
		# Inverse rotate the point to get the correct position in rotated space
		var rotation_radians = -tilemap.rotation
		rotated_pos = Vector2(
			world_pos.x * cos(rotation_radians) - world_pos.y * sin(rotation_radians),
			world_pos.x * sin(rotation_radians) + world_pos.y * cos(rotation_radians)
		)
	
	# Convert position to tile coordinates
	var coords = tilemap.local_to_map(rotated_pos)
	
	var atlas_coords = CoordinateUtils.to_atlas_coords(block_id)
	var existing_atlas_coords = tilemap.get_cell_atlas_coords(coords)
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
