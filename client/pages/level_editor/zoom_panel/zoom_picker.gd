extends Node2D

signal editor_camera_zoom_change

@onready var down_button = $DownButton
@onready var up_button = $UpButton
@onready var label = $Label

var text: String = "%"
var zoom_increment: int = 3
var min_zoom_increment: int = 0
var max_zoom_increment: int = 6
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
	zoom_increment = clamp(zoom_increment, min_zoom_increment, max_zoom_increment)
	label.text = str(zoom_amounts[zoom_increment]) + "%"
	emit_signal("editor_camera_zoom_change", 0.5 * zoom_amounts[zoom_increment] / 100.0)
# 	NOTE - If in future this is changed to allow custom zoom amounts (variable name: zoom_amount), remove the line above and keep the code and comment below.
#	if (typeof(zoom_amount) == 2 || typeof(zoom_amount) == 3): #Check if integer or float
#		if not(is_nan(zoom_amount) || is_inf(zoom_amount) || zoom_amount == 0): #Disallow zero, NaN, and infinity (positive or negative)
#			emit_signal("editor_camera_zoom_change", 0.5 * zoom_amount / 100.0)
