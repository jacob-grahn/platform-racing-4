extends Node2D
class_name Cursor

signal level_event

@onready var control = $Control
@onready var block_cursor = $BlockCursor
@onready var draw_cursor = $DrawCursor
@onready var erase_cursor = $EraseCursor
@onready var usertext_cursor = $UserTextCursor

var using_gui = false
var mouse_down = false
var current_cursor: Node2D


func _ready():
	var editor_menu = get_node("../EditorMenu")
	editor_menu.connect("control_event", _on_control_event)
	control.connect("gui_input", _on_gui_input)
	
	for child in get_children():
		child.connect("level_event", _on_subcursor_event)


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


func _on_control_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SELECT_BLOCK:
		current_cursor = block_cursor
	if event.type == EditorEvents.SELECT_TOOL:
		$Control.mouse_filter = 0
		if event.tool == "blocks":
			current_cursor = block_cursor
		if event.tool == "draw":
			current_cursor = draw_cursor
		if event.tool == "erase":
			current_cursor = erase_cursor
		if event.tool == "text":
			current_cursor = usertext_cursor
			$Control.mouse_filter = 1


func _on_subcursor_event(event: Dictionary) -> void:
	emit_signal("level_event", event)
	
