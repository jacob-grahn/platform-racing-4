extends Node2D
class_name EditorEvents

signal level_event

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
const LAYER_DEPTH = 'layer_depth'
const UNDO = 'undo'

var events = []
var redo_events = []


func _ready():
	get_node("../UI/Cursor").connect("level_event", _on_level_event)
	get_node("../UI/EditorMenu").connect("level_event", _on_level_event)


func _on_level_event(event: Dictionary) -> void:
	print("EditorEvents::_on_level_event ", event)
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	emit_signal("level_event", event)


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
	
