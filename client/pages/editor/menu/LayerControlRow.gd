extends SliderRow

signal level_event

@onready var rotation_picker = $RotationPicker
var layer_name: String = ""


func _ready():
	rotation_picker.min = -180
	rotation_picker.max = 180
	rotation_picker.text = "Rotation"
	rotation_picker.step = 10
	rotation_picker.connect("value_change", _on_rotation_change)
	add_slider(rotation_picker)


func _on_rotation_change(rotation):
	emit_signal("level_event", {
		"type": EditorEvents.ROTATE_LAYER,
		"layer_name": layer_name,
		"rotation": rotation
	})
