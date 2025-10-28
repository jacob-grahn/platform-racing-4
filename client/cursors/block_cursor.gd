extends Node2D

signal level_event

@onready var eraser_icon = $EraserIcon
@onready var block_icon = $BlockIcon
@onready var teleport_colorin = $BlockIcon/TeleportColorin

var active: bool = false
var mode: String = "draw"
var block_id: int = 0
var teleport_colorin_coords: Vector2 = Vector2(-1, -1)
var teleport_color: String = "FFFFFF"
var grabbed_block: int = 0
var layers: Layers


func _ready():
	pass


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		eraser_icon.visible = false
		block_icon.visible = false
		teleport_colorin.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			if mode == "erase":
				eraser_icon.visible = true
			elif mode == "move" and grabbed_block > 0 or mode == "draw":
				block_icon.visible = true
				var atlas_coords: Vector2i = Vector2i(-1, -1)
				if mode == "move":
					atlas_coords = CoordinateUtils.to_atlas_coords(grabbed_block)
				else:
					atlas_coords = CoordinateUtils.to_atlas_coords(block_id)
				block_icon.texture.region = Rect2((128 * atlas_coords.x), (128 * atlas_coords.y), 128, 128)
				if teleport_colorin_coords != Vector2(-1, -1):
					teleport_colorin.visible = true
					teleport_colorin.texture.region = Rect2((128 * teleport_colorin_coords.x), (128 * teleport_colorin_coords.y), 128, 128)
					teleport_colorin.self_modulate = Color(teleport_color + "7F")
	else:
		visible = false


func init(_menu, _layers) -> void:
	print("BlockCursor::init")
	layers = _layers
	_menu.connect("control_event", _on_control_event)
	

func _on_control_event(event: Dictionary) -> void:
	print("BlockCursor::_on_control_event", event)
	if event.type == EditorEvents.SELECT_BLOCK_MODE:
		mode = event.mode
	if event.type == EditorEvents.SELECT_BLOCK:
		block_id = event.block_id
		if "teleport_colorin_coords" in event and "teleport_color" in event:
			teleport_colorin_coords = event.teleport_colorin_coords
			teleport_color = event.teleport_color
		else:
			teleport_colorin_coords = Vector2(-1, -1)
			teleport_color = "FFFFFF"
			


func get_mouse_to_tilemap_coords(pos: Vector2 = Vector2(-1, -1)) -> Vector2:
	var layer: ParallaxBackground = layers.block_layers.get_node(layers.get_target_block_layer())
	var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var rotated_pos: Vector2

	if pos != Vector2(-1, -1):
		rotated_pos = pos
	else:
		# Get screen position of mouse
		var viewport_mouse_pos = get_viewport().get_mouse_position()
		
		# Convert to world position taking into account camera position, zoom, and layer scale
		var world_pos = (viewport_mouse_pos - get_viewport_rect().size / 2) / camera.zoom.x
		world_pos += camera.position
		
		# Adjust for layer depth scaling
		world_pos *= layer.follow_viewport_scale
		
		# Account for tilemap rotation
		rotated_pos = world_pos
		if tile_map_layer.rotation != 0:
			# Inverse rotate the point to get the correct position in rotated space
			var rotation_radians = -tile_map_layer.rotation
			rotated_pos = Vector2(
				world_pos.x * cos(rotation_radians) - world_pos.y * sin(rotation_radians),
				world_pos.x * sin(rotation_radians) + world_pos.y * cos(rotation_radians)
			)
	return rotated_pos


func on_mouse_down():
	if active and mode == "move":
		var layer: ParallaxBackground = layers.block_layers.get_node(layers.get_target_block_layer())
		var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_coords = tile_map_layer.get_cell_atlas_coords(coords)
		var tile_id = CoordinateUtils.to_block_id(tile_coords)
		if tile_id > 0:
			grabbed_block = tile_id
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": layers.get_target_block_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": 0,
				"atlas_coords": Vector2(-1, -1)
			})

func on_drag():
	if active and (mode == "draw" or mode == "erase"):
		var layer: ParallaxBackground = layers.block_layers.get_node(layers.get_target_block_layer())
		var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var tile_id: int
		if mode == "erase":
			tile_id = 0
		else:
			tile_id = block_id
		var atlas_coords = CoordinateUtils.to_atlas_coords(tile_id)
		var existing_atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
		if atlas_coords != existing_atlas_coords:
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": layers.get_target_block_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": tile_id,
				"atlas_coords": atlas_coords
			})


func on_mouse_up():
	if active and mode == "move":
		var layer: ParallaxBackground = layers.block_layers.get_node(layers.get_target_block_layer())
		var tile_map_layer: TileMapLayer = layer.get_node("TileMapLayer")
		var coords = tile_map_layer.local_to_map(get_mouse_to_tilemap_coords())
		var atlas_coords = CoordinateUtils.to_atlas_coords(grabbed_block)
		if grabbed_block > 0:
			emit_signal("level_event", {
				"type": EditorEvents.SET_TILE,
				"layer_name": layers.get_target_block_layer(),
				"coords": {
					"x": coords.x,
					"y": coords.y
				},
				"block_id": grabbed_block,
				"atlas_coords": atlas_coords
			})
			grabbed_block = 0
