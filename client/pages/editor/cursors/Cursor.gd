extends Node2D
class_name Cursor

signal event

@onready var control = $Control
@onready var block_cursor = $BlockCursor
@onready var draw_cursor = $DrawCursor

var using_gui = false
var mouse_down = false
var current_cursor: Node2D
var layer_name: String = "Layer 1"


func _ready():
	var slider_menu = get_parent().get_node("SliderMenu")
	slider_menu.connect("control_changed", _on_control_changed)
	control.connect("gui_input", _on_gui_input)
	
	for child in get_children():
		child.connect("event", _on_subcursor_event)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		using_gui = false


func _process(delta):
	if Input.is_mouse_button_pressed(1) && !using_gui: # Left click
		if !mouse_down:
			current_cursor.on_mouse_down()
			mouse_down = true
		current_cursor.on_drag()
	else:
		if mouse_down:
			current_cursor.on_mouse_up()
			mouse_down = false
		using_gui = true


func _on_control_changed(control: String) -> void:
	if control == "Blocks":
		current_cursor = block_cursor
	if control == "Draw":
		current_cursor = draw_cursor


func _on_subcursor_event(event: Dictionary) -> void:
	emit_signal("event", event)
	
