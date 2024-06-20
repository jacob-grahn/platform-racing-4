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


func _on_up_button_pressed():
	value += step
	_on_change()


func _on_down_button_pressed():
	value -= step
	_on_change()


func _on_change():
	value = clamp(value, min, max)
	emit_signal("value_change", value)
	label.text = text + ": " + str(value)

