extends Node2D

signal editor_camera_zoom_change

@onready var down_button = $DownButton
@onready var up_button = $UpButton
@onready var label = $Label

var text: String = "%"
var zoom_increment: int = 3
var min: int = 0
var max: int = 6
var step: int = 1
var zoom_amounts: Array = [25, 50, 75, 100, 150, 250, 500] #Zoom amounts listed in percentage.


func _ready():
	up_button.connect("pressed", _on_up_button_pressed)
	down_button.connect("pressed", _on_down_button_pressed)


func _on_up_button_pressed():
	zoom_increment += step
	_on_change()


func _on_down_button_pressed():
	zoom_increment -= step
	_on_change()


func _on_change():
	zoom_increment = clamp(zoom_increment, min, max)
	label.text = str(zoom_amounts[zoom_increment]) + "%"
	emit_signal("editor_camera_zoom_change", zoom_amounts[zoom_increment] / 100.0)
