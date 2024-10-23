extends Node2D

signal value_change

@onready var down_button = $DownButton
@onready var up_button = $UpButton
@onready var label = $Label
@onready var camera = $Camera

var text: String = "%"
var value: int = 4
var min: int = 1
var max: int = 7
var step: int = 1
var camera_zoom: float = 1


func _ready():
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
	match value:
		1:
			camera_zoom = 0.25
			text = "25"
		2:
			camera_zoom = 0.5
			text = "50"
		3:
			camera_zoom = 0.75
			text = "75"
		4:
			camera_zoom = 1
			text = "100"
		5:
			camera_zoom = 1.5
			text = "150"
		6:
			camera_zoom = 2.5
			text = "250"
		7:
			camera_zoom = 5
			text = "500"
	label.text = str(text) + "%"


func set_value(new_value: int) -> void:
	value = new_value
	_render()
