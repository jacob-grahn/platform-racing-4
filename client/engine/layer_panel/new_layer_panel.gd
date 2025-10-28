extends Node2D

signal level_event
signal control_event

const LAYER = preload("res://layers/layer.tscn")
const LAYER_ROW = preload("res://engine/layer_panel/new_layer_row.tscn")

var layers: Node2D
var show_layer_type: String = "blocks"
@onready var row_holder = $ScrollContainer/RowHolder
@onready var new_button = $NewButton
@onready var delete_button = $DeleteButton
@onready var z_axis_container = $ZAxisContainer
@onready var depth_container = $DepthContainer
@onready var rotation_container = $RotationContainer
@onready var alpha_container = $AlphaContainer
@onready var z_axis_box = $ZAxisContainer/ZAxisBox
@onready var depth_box = $DepthContainer/DepthBox
@onready var rotation_box = $RotationContainer/RotationBox
@onready var alpha_box = $AlphaContainer/AlphaBox
@onready var rename_layer = $NewLayerNamePopup/RenameLayerPanel
@onready var new_layer_name_popup: Popup = $NewLayerNamePopup

func _ready():
	new_button.pressed.connect(_new_pressed)
	delete_button.pressed.connect(_delete_pressed)
	
	# depth_box.connect("text_changed", _depth_change.bind(depth_box.text))
	z_axis_box.connect("text_changed", _z_axis_change.bind())
	rotation_box.connect("text_changed", _rotation_change.bind())
	# alpha_box.connect("text_changed", _alpha_change.bind(alpha_box.text))
	new_layer_name_popup.connect("popup_hide", rename_layer._set_new_name)
	rename_layer.connect("name_change", _set_layer_name)


func init(new_layers: Node2D, new_show_layer_type: String) -> void:
	layers = new_layers
	show_layer_type = new_show_layer_type
	render()


func render() -> void:
	clear()
	var layer_array
	var target_layer
	if show_layer_type == "blocks":
		layer_array = layers.block_layers.get_children()
		target_layer = layers.get_target_block_layer()
	if show_layer_type == "art":
		layer_array = layers.art_layers.get_children()
		target_layer = layers.get_target_art_layer()
	var i: int = 0
	for layer in layer_array:
		if not (layer is Layer or layer is BlockLayer or layer is ArtLayer):
			continue
		i += 1
		var row = LAYER_ROW.instantiate()
		row.name = "LayerRow" + str(i)
		row.position.y = (row_holder.get_child_count() * 30)
		row.get_node("LayerNameButton").text = layer.name
		row_holder.add_child(row)
		
		var layer_button = row.get_node("LayerNameButton")
		layer_button.pressed.connect(_row_pressed.bind(layer.name, layer_button.global_position.x, layer_button.global_position.y))
		if target_layer == layer.name:
			layer_button.button_pressed = true
		
	update_boxes()


func update_boxes() -> void:
	var layer
	depth_container.visible = false
	alpha_container.visible = false
	if show_layer_type == "blocks":
		layer = layers.block_layers.get_node(layers.get_target_block_layer())
	if show_layer_type == "art":
		layer = layers.art_layers.get_node(layers.get_target_art_layer())
	if layer and (layer is Layer or layer is BlockLayer or layer is ArtLayer):
		if layer is BlockLayer:
			z_axis_box.text = str(layer.z_axis)
			rotation_box.text = str(layer.tile_map_rotation)
		if layer is ArtLayer:
			depth_container.visible = true
			alpha_container.visible = true
			z_axis_box.text = "1"
			depth_box.text = str(layer.depth)
			rotation_box.text = str(round(layer.get_node("Lines").rotation_degrees))
			alpha_box.text = str(layer.get_node("Lines").modulate)

func clear() -> void:
	for child in row_holder.get_children():
		child.free()


func _new_pressed():
	print("LayerPanel::add layer")
	if show_layer_type == "blocks":
		var i = layers.block_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(layers.block_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("level_event", {
			"type": EditorEvents.ADD_BLOCK_LAYER,
			"name": new_name
		})
		call_deferred("render")
	if show_layer_type == "art":
		var i = layers.art_layers.get_child_count() + 1
		var new_name = "Layer " + str(i)
		while(layers.art_layers.get_node(new_name)):
			i += 1
			new_name = "Layer " + str(i)
		emit_signal("level_event", {
			"type": EditorEvents.ADD_ART_LAYER,
			"name": new_name
		})
		call_deferred("render")


func _delete_pressed():
	if show_layer_type == "blocks":
		emit_signal("level_event", {
			"type": EditorEvents.DELETE_BLOCK_LAYER,
			"name": layers.get_target_block_layer()
		})
		call_deferred("render")
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.DELETE_ART_LAYER,
			"name": layers.get_target_art_layer()
		})
		call_deferred("render")


func _row_pressed(layer_name: String, x: float, y: float):
	if show_layer_type == "blocks":
		print(layers.get_target_block_layer())
		if layers.get_target_block_layer() == layer_name:
			rename_layer.new_layer_name.text = layer_name
			new_layer_name_popup.popup(Rect2i(x, y, 276, 38))
		else:
			layers.set_target_block_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_BLOCK_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")
	if show_layer_type == "art":
		if layers.get_target_art_layer() == layer_name:
			rename_layer.new_layer_name.text = layer_name
			new_layer_name_popup.popup(Rect2i(x, y, 276, 38))
		else:
			layers.set_target_art_layer(layer_name)
			emit_signal("control_event", {
				"type": EditorEvents.SELECT_ART_LAYER,
				"layer_name": layer_name
			})
			call_deferred("render")


func _z_axis_change(z_axis):
	if z_axis.is_valid_int():
		if show_layer_type == "blocks":
			var new_z_axis: float
			if int(z_axis) >= 1 and int(z_axis) <= 16:
				new_z_axis = str(z_axis).to_float()
			else:
				if int(z_axis) < 1:
					new_z_axis = 1
				else:
					new_z_axis = 16
			emit_signal("level_event", {
				"type": EditorEvents.SET_BLOCK_LAYER_Z_AXIS,
				"layer_name": layers.get_target_block_layer(),
				"z_axis": new_z_axis
			})
		if show_layer_type == "art":
			var new_z_axis: int
			if int(z_axis) >= 0 and int(z_axis) <= 50:
				new_z_axis = str(z_axis).to_float()
			else:
				if int(z_axis) < 0:
					new_z_axis = 0
				else:
					new_z_axis = 50
			emit_signal("level_event", {
				"type": EditorEvents.SET_ART_LAYER_Z_AXIS,
				"layer_name": layers.get_target_art_layer(),
				"z_axis": new_z_axis
			})
	else:
		if show_layer_type == "blocks":
			var layer = layers.block_layers.get_node(layers.get_target_block_layer())
			z_axis_box.text = str(layer.z_axis)
		if show_layer_type == "art":
			var layer = layers.art_layers.get_node(layers.get_target_art_layer())
			z_axis_box.text = str(layer.z_axis)


func _depth_change(depth):
	if depth.is_valid_float():
		if show_layer_type == "art":
			var new_depth: float
			if depth >= 0 and depth <= 50:
				new_depth = str(depth).to_float()
			else:
				if new_depth < 0:
					new_depth = 0
				else:
					new_depth = 50
			emit_signal("level_event", {
				"type": EditorEvents.SET_ART_LAYER_DEPTH,
				"layer_name": layers.get_target_art_layer(),
				"depth": new_depth
			})
	else:
		if show_layer_type == "art":
			var layer = layers.art_layers.get_node(layers.get_target_art_layer())
			depth_box.text = str(layer.depth)


func _rotation_change(rotation):
	if rotation.is_valid_float():
		var new_rotation: float
		if float(rotation) >= -360 and float(rotation) <= 360:
			new_rotation = rotation.to_float()
		else:
			if float(rotation) < -360:
				new_rotation = -360
			else:
				new_rotation = 360
		if show_layer_type == "blocks":
			emit_signal("level_event", {
			"type": EditorEvents.SET_BLOCK_LAYER_ROTATION,
			"layer_name": layers.get_target_block_layer(),
			"tile_map_rotation": new_rotation
			})
		if show_layer_type == "art":
			emit_signal("level_event", {
				"type": EditorEvents.SET_ART_LAYER_DEPTH,
				"layer_name": layers.get_target_art_layer(),
				"rotation": new_rotation
			})
	else:
		if show_layer_type == "blocks":
			var layer = layers.block_layers.get_node(layers.get_target_block_layer())
			rotation_box.text = str(layer.tile_map_rotation)
		if show_layer_type == "art":
			var layer = layers.art_layers.get_node(layers.get_target_art_layer())
			rotation_box.text = str(layer.rotation)


func _alpha_change(alpha):
	if alpha.is_valid_float():
		var new_alpha: float
		if alpha >= 0 and alpha <= 100:
			new_alpha = alpha.to_float()
		else:
			if new_alpha < 0:
				new_alpha = 0
			else:
				new_alpha = 100
		if show_layer_type == "art":
			emit_signal("level_event", {
				"type": EditorEvents.SET_ART_LAYER_ALPHA,
				"layer_name": layers.get_target_art_layer(),
				"rotation": new_alpha
			})
	else:
		if show_layer_type == "art":
			var layer = layers.art_layers.get_node(layers.get_target_art_layer())
			alpha_box.text = str(layer.alpha)


func _set_layer_name(new_layer_name):
	if show_layer_type == "blocks":
		emit_signal("level_event", {
			"type": EditorEvents.RENAME_BLOCK_LAYER,
			"layer_name": layers.get_target_block_layer(),
			"new_layer_name": new_layer_name
		})
		new_layer_name_popup.visible = false
		render()
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.RENAME_ART_LAYER,
			"layer_name": layers.get_target_art_layer(),
			"new_layer_name": new_layer_name
		})
		new_layer_name_popup.visible = false
		render()
