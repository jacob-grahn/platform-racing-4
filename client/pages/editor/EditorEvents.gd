extends Node2D
class_name EditorEvents

signal level_event
signal send_level_event

@onready var game_client: Node2D = get_node("/root/Main/GameClient")

# control events, switching tools, swtiching selected block, etc
const SELECT_TOOL = 'select_tool'
const SELECT_BLOCK = 'select_block'
const SELECT_LAYER = 'select_layer'

# level events, adding blocks, drawing, changeing a setting, etc
const SET_TILE = 'set_tile'
const ADD_LINE = 'add_line'
const ADD_LAYER = 'add_layer'
const ADD_USERTEXT = 'add_usertext'
const ROTATE_LAYER = 'rotate_layer'
const DELETE_LAYER = 'delete_layer'
const LAYER_DEPTH = 'layer_depth'
const UNDO = 'undo'
const SET_BACKGROUND = 'set_background'

var events = []
var redo_events = []
var edit_id_buffer = {}

var last_processed_edit_id = -1
var last_send_event: Dictionary = {}
var processing_edit_id = false

func _ready():
	get_node("../UI/Cursor").connect("level_event", _on_level_event)
	get_node("../UI/EditorMenu").connect("level_event", _on_level_event)
	get_node("../UI/LayerPanel").connect("level_event", _on_level_event)
	get_node("/root/Main/GameClient").connect("receive_level_event", _on_receive_level_event)

func _process(delta):
	if not processing_edit_id:
		processing_edit_id = true
		process_edit_id_buffer()
		processing_edit_id = false
	
func _on_level_event(event: Dictionary) -> void:
	if event == last_send_event:
		return
		
	last_send_event = event
	print("EditorEvents::_on_level_event ", event)
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	
	if !game_client.is_live_editing:
		# Single-player level editor
		emit_signal("level_event", event)
	else:
		# Muti-player level editor
		emit_signal("send_level_event", event)

func _on_receive_level_event(event: Dictionary) -> void:
	var edit_id = event.get("edit_id", -1)
	if edit_id == -1:
		return
	edit_id_buffer[int(edit_id)] = event

func process_edit_id_buffer() -> void:
	var local_edit_id = Session.get_local_edit_id()
	while edit_id_buffer.has(local_edit_id):
		if local_edit_id < last_processed_edit_id:
			edit_id_buffer.erase(local_edit_id)
			local_edit_id += 1
			continue
		
		last_processed_edit_id = local_edit_id
		var event = edit_id_buffer[local_edit_id]
		print("EditorEvents::_on_receive_level_event ", event)
		if len(redo_events) > 0:
			redo_events = []
		events.push_back(event)
		emit_signal("level_event", event)
		edit_id_buffer.erase(local_edit_id)
		
		local_edit_id += 1
		
	processing_edit_id = false
	
	Session.set_local_edit_id(local_edit_id)
		
func undo() -> void:
	var event = events.pop_back()
	redo_events.push_back(event)
	var undo_event = {
		"type": UNDO,
		"event": event
	}
	emit_signal("level_event", undo_event)


func redo() -> void:
	if len(redo_events) == 0:
		return
	var event = redo_events.pop_back()
	events.push_back(event)
	emit_signal("level_event", event)
	
