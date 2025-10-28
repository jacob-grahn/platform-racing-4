extends Node2D
class_name Cursor

signal level_event

var touching_gui = false
var using_gui = false
var mouse_down = false
var old_cursor: String
var current_cursor: Node2D
var menu: EditorMenu

@onready var control = $Control
@onready var block_cursor = $BlockCursor
@onready var draw_cursor = $DrawCursor
@onready var erase_cursor = $EraseCursor
@onready var text_cursor = $TextCursor
@onready var cursor_icon = $CursorIcon
@onready var cursor_colorin = $CursorIcon/CursorColorIn
@onready var cursor_outline = $CursorIcon/CursorOutline


func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor_colorin.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	cursor_outline.self_modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
	cursor_icon.visible = false

func _exit_tree() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass


func init(_menu, layers) -> void:
	print("Cursor::init")
	menu = _menu
	
	block_cursor.init(menu, layers)
	draw_cursor.init(menu, layers)
	erase_cursor.init(layers)
	text_cursor.init(layers)
	
	menu.control_event.connect(_on_control_event)
	control.gui_input.connect(_on_gui_input)
	control.mouse_entered.connect(_on_mouse_entered)
	control.mouse_exited.connect(_on_mouse_exited)
	
	for child in get_children():
		if child.has_signal("level_event"):
			child.level_event.connect(_on_subcursor_event)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		using_gui = false


func _on_mouse_entered():
	touching_gui = true


func _on_mouse_exited():
	touching_gui = false


func _physics_process(_delta):
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


# block_id = event.block_id

func _on_control_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SELECT_BLOCK:
		if current_cursor:
			current_cursor.deactivate()
		current_cursor = block_cursor
		current_cursor.activate()
	elif event.type == EditorEvents.SELECT_TOOL:
		$Control.mouse_filter = 0
		if current_cursor:
			current_cursor.deactivate()
		if event.tool == "blocks":
			current_cursor = block_cursor
		elif event.tool == "draw" or event.tool == "erase":
			current_cursor = draw_cursor
		elif event.tool == "stamp":
			current_cursor = erase_cursor
		elif event.tool == "text":
			current_cursor = text_cursor
			$Control.mouse_filter = 1
		current_cursor.activate()
	elif event.type == EditorEvents.SET_BRUSH_SIZE:
		if current_cursor == draw_cursor:
			draw_cursor.set_brush_size(event.size)
	elif event.type == EditorEvents.SET_BRUSH_COLOR:
		if current_cursor == draw_cursor:
			# Convert hex string to Color object
			draw_cursor.set_brush_color(event.color)
	elif event.type == EditorEvents.SET_BRUSH_ALPHA:
		if current_cursor == draw_cursor:
			# Convert hex string to Color object
			draw_cursor.set_brush_alpha(event.alpha)


func _on_subcursor_event(event: Dictionary) -> void:
	level_event.emit(event)
