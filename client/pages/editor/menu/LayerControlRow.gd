extends SliderRow

signal level_event

const NUMBER_PICKER: PackedScene = preload("res://pages/editor/menu/NumberPicker.tscn")
var layer_name: String = ""
var rotation_picker: Node2D
var depth_picker: Node2D


func _ready():
	rotation_picker = NUMBER_PICKER.instantiate()
	rotation_picker.text = "Rotation"
	rotation_picker.min = -180
	rotation_picker.max = 180
	rotation_picker.step = 10
	rotation_picker.connect("value_change", _on_rotation_change)
	add_slider(rotation_picker)
	
	depth_picker = NUMBER_PICKER.instantiate()
	depth_picker.text = "Depth"
	depth_picker.min = 1
	depth_picker.max = 16
	depth_picker.step = 1
	depth_picker.connect("value_change", _on_depth_change)
	add_slider(depth_picker)
	
	var cursor = get_node("../../../UI/Cursor")
	set_layer_name(cursor.layer_name)


func set_layer_name(new_layer_name: String) -> void:
	layer_name = new_layer_name
	var layer = get_node("../../../Layers/" + layer_name)
	depth_picker.set_value(round(layer.follow_viewport_scale * 10))
	rotation_picker.set_value(round(layer.get_node("TileMap").rotation_degrees))


func _on_rotation_change(rotation):
	emit_signal("level_event", {
		"type": EditorEvents.ROTATE_LAYER,
		"layer_name": layer_name,
		"rotation": rotation
	})


func _on_depth_change(depth):
	emit_signal("level_event", {
		"type": EditorEvents.LAYER_DEPTH,
		"layer_name": layer_name,
		"depth": depth
	})
