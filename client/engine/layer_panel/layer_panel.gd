extends Node2D

signal level_event
signal control_event

const LAYER = preload("res://layers/layer.tscn")
const LAYER_ROW = preload("res://engine/layer_panel/layer_row.tscn")

var layers: Node2D
var show_layer_type: String = "blocks"
@onready var row_holder = $ScrollContainer/RowHolder
@onready var new_button = $NewButton
@onready var delete_button = $DeleteButton
@onready var rotation_picker = $LayerSettingsPopup/RotationPicker
@onready var depth_picker = $LayerSettingsPopup/DepthPicker
@onready var rename_layer = $NewLayerNamePopup/RenameLayerPanel
@onready var layer_settings_popup: Popup = $LayerSettingsPopup
@onready var new_layer_name_popup: Popup = $NewLayerNamePopup


func _ready():
	new_button.pressed.connect(_new_pressed)
	delete_button.pressed.connect(_delete_pressed)
	
	rotation_picker.text = "Rotation"
	rotation_picker.min = -180
	rotation_picker.max = 180
	rotation_picker.step = 10
	rotation_picker.connect("value_change", _rotation_change)
	
	depth_picker.text = "Depth"
	depth_picker.min = 1
	depth_picker.max = 16
	depth_picker.step = 1
	depth_picker.connect("value_change", _depth_change)
	
	rename_layer.connect("name_change", _set_layer_name)


func init(new_layers: Node2D) -> void:
	layers = new_layers
	render()


func render() -> void:
	clear()
	var layer_array
	if show_layer_type == "blocks":
		layer_array = layers.block_layers.get_children()
	if show_layer_type == "art":
		layer_array = layers.art_layers.get_children()
	for layer in layer_array:
		if not (layer is Layer or layer is BlockLayer or layer is ArtLayer):
			continue
		var row = LAYER_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("Label").text = layer.name
		row_holder.add_child(row)
		
		var label_button = row.get_node("LabelButton")
		var visible_button = row.get_node("VisibleButton")
		label_button.pressed.connect(_row_pressed.bind(layer.name))
		if layers.get_target_layer() == layer.name:
			label_button.button_pressed = true
		
		row.get_node("RenameButton").pressed.connect(_row_layer_name_pressed.bind(layer.name))
		row.get_node("VisibleButton").pressed.connect(_row_visible_pressed.bind(layer.name, visible_button))
		row.get_node("GearButton").pressed.connect(_row_config_pressed.bind(layer.name))
	update_pickers()


func update_pickers() -> void:
	var layer
	if show_layer_type == "blocks":
		layer = layers.block_layers.get_node(layers.get_target_block_layer())
	if show_layer_type == "art":
		layer = layers.art_layers.get_node(layers.get_target_art_layer())
	if layer and (layer is Layer or layer is BlockLayer or layer is ArtLayer):
		depth_picker.set_value(layer.depth)
		if layer is BlockLayer:
			rotation_picker.set_value(round(layer.get_node("TileMapLayer").rotation_degrees))
		if layer is ArtLayer:
			rotation_picker.set_value(round(layer.get_node("Lines").rotation_degrees))

func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()


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


func _row_pressed(layer_name: String):
	if show_layer_type == "blocks":
		layers.set_target_block_layer(layer_name)
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_BLOCK_LAYER,
			"layer_name": layer_name
		})
	if show_layer_type == "art":
		layers.set_target_art_layer(layer_name)
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_ART_LAYER,
			"layer_name": layer_name
		})


func _row_layer_name_pressed(layer_name: String):
	_row_pressed(layer_name)
	var mouse_pos := get_global_mouse_position()
	rename_layer.new_layer_name.text = layer_name
	new_layer_name_popup.popup(Rect2i(mouse_pos.x, mouse_pos.y, 380, 64))


func _row_visible_pressed(layer_name: String, Button):
	_row_pressed(layer_name)
	var visibility = true
	if Button.modulate.a > 0.5:
		Button.modulate.a = 0.5
		visibility = false
	else:
		Button.modulate.a = 1
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_ALPHA,
			"layer_name": layer_name,
			"visibility": visibility
		})


func _row_config_pressed(layer_name: String):
	_row_pressed(layer_name)
	update_pickers()
	var mouse_pos := get_global_mouse_position()
	layer_settings_popup.popup(Rect2i(mouse_pos.x, mouse_pos.y, 308, 112))


func _rotation_change(rotation):
	if show_layer_type == "blocks":
		emit_signal("level_event", {
			"type": EditorEvents.SET_BLOCK_LAYER_ROTATION,
			"layer_name": layers.get_target_block_layer(),
			"tile_map_rotation": rotation
		})
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_ROTATION,
			"layer_name": layers.get_target_art_layer(),
			"rotation": rotation
		})


func _depth_change(depth):
	if show_layer_type == "art":
		emit_signal("level_event", {
			"type": EditorEvents.SET_ART_LAYER_DEPTH,
			"layer_name": layers.get_target_art_layer(),
			"depth": depth
		})

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
