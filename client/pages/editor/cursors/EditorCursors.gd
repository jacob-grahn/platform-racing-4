extends Node2D

@onready var layers = $"../../Layers"
const Editor_Cursor = preload("res://pages/editor/cursors/EditorCursor.tscn")
var cursor: Node2D = null

func _ready():
	pass

func add_new_cursor(userID: String):
	if userID == Session.get_username():
		return
		
	for child: Node2D in get_children():
		if child.name == userID:
			return
	
	cursor = Editor_Cursor.instantiate()
	cursor.name = userID
	add_child(cursor)
	cursor.initialise(userID)
			
func update_cursor_position(userID: String, pos: Vector2, layer: String):
	for child: Node2D in get_children():
		if child.name == userID:
			child.position = pos
		
		#if layer == layers.get_target_layer():
			#child.visible = true
		#else:
			#child.visible = false
