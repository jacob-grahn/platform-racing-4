extends Node2D
class_name Cursor

signal level_event

var using_gui = false
var mouse_down = false
var current_cursor: Node2D
var menu: EditorMenu

@onready var control = $Control
@onready var block_cursor = $BlockCursor
@onready var draw_cursor = $DrawCursor
@onready var erase_cursor = $EraseCursor
@onready var user_text_cursor = $UserTextCursor
@onready var cursor_colorin = $VariousCursors/CursorSprite/CursorColorIn
@onready var cursor_outline = $VariousCursors/CursorSprite/CursorOutline


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor_colorin.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	cursor_outline.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))

func _exit_tree() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func init(_menu, layers) -> void:
	print("Cursor::init")
	menu = _menu
	
	block_cursor.init(menu, layers)
	draw_cursor.init(layers)
	erase_cursor.init(layers)
	user_text_cursor.init(layers)
	
	menu.control_event.connect(_on_control_event)
	control.gui_input.connect(_on_gui_input)
	
	for child in get_children():
		if child.has_signal("level_event"):
			child.level_event.connect(_on_subcursor_event)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		using_gui = false


func _process(_delta):
	global_position = get_global_mouse_position()
	if current_cursor != null and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !using_gui: # Left click
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
	elif event.type == EditorEvents.SELECT_TOOL:
		$Control.mouse_filter = 0
		if event.tool == "blocks":
			current_cursor = block_cursor
		if event.tool == "draw":
			current_cursor = draw_cursor
		if event.tool == "erase":
			current_cursor = erase_cursor
		if event.tool == "text":
			current_cursor = user_text_cursor
			$Control.mouse_filter = 1
	elif event.type == EditorEvents.SET_BRUSH_SIZE:
		if current_cursor == draw_cursor:
			draw_cursor.set_brush_size(event.size)
	elif event.type == EditorEvents.SET_BRUSH_COLOR:
		if current_cursor == draw_cursor:
			# Convert hex string to Color object
			var color = Color(event.color)
			draw_cursor.set_brush_color(color)


func _on_subcursor_event(event: Dictionary) -> void:
	level_event.emit(event)
