extends Node2D

signal level_event
signal control_event

const LAYER = preload("res://layers/layer.tscn")
const LAYER_ROW = preload("res://pages/editor/layer_panel/layer_row.tscn")

var layers: Node2D
@onready var row_holder = $ScrollContainer/RowHolder
@onready var new_button = $NewButton
@onready var delete_button = $DeleteButton
@onready var rotation_picker = $Popup/RotationPicker
@onready var depth_picker = $Popup/DepthPicker
@onready var popup: Popup = $Popup


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


func init(new_layers: Node2D) -> void:
	layers = new_layers
	render()


func render() -> void:
	clear()
	var layer_array = layers.get_children()
	for layer in layer_array:
		var row = LAYER_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("Label").text = layer.name
		row_holder.add_child(row)
		
		var label_button = row.get_node("LabelButton")
		label_button.pressed.connect(_row_pressed.bind(layer.name))
		if layers.get_target_layer() == layer.name:
			label_button.button_pressed = true
		
		row.get_node("VisibleButton").pressed.connect(_row_visible_pressed.bind(layer.name))
		row.get_node("GearButton").pressed.connect(_row_config_pressed.bind(layer.name))
	update_pickers()


func update_pickers() -> void:
	var layer = layers.get_node(layers.get_target_layer())
	if layer:
		depth_picker.set_value(layer.depth)
		rotation_picker.set_value(round(layer.get_node("TileMap").rotation_degrees))


func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()


func _new_pressed():
	print("LayerPanel::add layer")
	var i = layers.get_child_count() + 1
	var new_name = "Layer " + str(i)
	while(layers.get_node(new_name)):
		i += 1
		new_name = "Layer " + str(i)
	emit_signal("level_event", {
		"type": EditorEvents.ADD_LAYER,
		"name": new_name
	})
	call_deferred("render")


func _delete_pressed():
	emit_signal("level_event", {
		"type": EditorEvents.DELETE_LAYER,
		"name": layers.get_target_layer()
	})
	call_deferred("render")


func _row_pressed(layer_name: String):
	layers.set_target_layer(layer_name)
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_LAYER,
		"layer_name": layer_name
	})


func _row_visible_pressed(layer_name: String):
	pass


func _row_config_pressed(layer_name: String):
	_row_pressed(layer_name)
	update_pickers()
	var mouse_pos := get_global_mouse_position()
	popup.popup(Rect2i(mouse_pos.x, mouse_pos.y, 470, 150))


func _rotation_change(rotation):
	emit_signal("level_event", {
		"type": EditorEvents.ROTATE_LAYER,
		"layer_name": layers.get_target_layer(),
		"rotation": rotation
	})


func _depth_change(depth):
	emit_signal("level_event", {
		"type": EditorEvents.LAYER_DEPTH,
		"layer_name": layers.get_target_layer(),
		"depth": depth
	})
