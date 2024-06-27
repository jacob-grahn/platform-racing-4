extends SliderItem

signal value_change

@onready var down_button = $Content/DownButton
@onready var up_button = $Content/UpButton
@onready var label = $Content/Label

var text: String = "Value"
var value: int = 0
var min: int = -1
var max: int = 1
var step: int = 1


func _ready():
	super._ready()
	up_button.connect("pressed", _on_up_button_pressed)
	down_button.connect("pressed", _on_down_button_pressed)
	_render()


func _on_up_button_pressed():
	value += step
	_on_change()


func _on_down_button_pressed():
	value -= step
	_on_change()


func _on_change():
	value = clamp(value, min, max)
	emit_signal("value_change", value)
	_render()


func _render():
	label.text = text + ": " + str(value)


func get_dimensions() -> Vector2:
	return Vector2i(640, 128)


func set_value(new_value: int) -> void:
	value = new_value
	_render()

