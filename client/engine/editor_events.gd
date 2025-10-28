extends Node2D
class_name EditorEvents

signal level_event
signal send_level_event

# control events, switching tools, swtiching selected block, etc
const SELECT_TOOL = 'select_tool'
const SELECT_LAYER = 'select_layer'
const ENABLE_COLLAB = 'enable_collab'
const SELECT_BLOCK = 'select_block'
const SELECT_BLOCK_MODE = 'select_block_mode'
const SELECT_BLOCK_LAYER = 'select_block_layer'
const SELECT_ART_MODE = 'select_art_mode'
const SELECT_ART_LAYER = 'select_art_layer'
const SET_BRUSH_SIZE = 'set_brush_size'
const SET_BRUSH_COLOR = 'set_brush_color'
const SET_BRUSH_ALPHA = 'set_brush_alpha'

# level events, adding blocks, drawing, changeing a setting, etc
const SET_TILE = 'set_tile'
const MOVE_TILE = 'move_tile'
const ADD_LINE = 'add_line'
const ADD_LAYER = 'add_layer'
const ADD_BLOCK_LAYER = 'add_block_layer'
const ADD_ART_LAYER = 'add_art_layer'
const ADD_TEXT = 'add_text'
const ROTATE_TEXT = 'rotate_text'
const SET_TEXT = 'set_text'
const SET_TEXT_SCALE = 'set_text_scale'
const SET_TEXT_FONT = 'set_text_font'
const SET_TEXT_COLOR = 'set_text_color'
const DELETE_TEXT = 'delete_text'
const ADD_STAMP = 'add_stamp'
const RENAME_LAYER = 'rename_layer'
const RENAME_BLOCK_LAYER = 'rename_block_layer'
const RENAME_ART_LAYER = 'rename_art_layer'
const DELETE_LAYER = 'delete_layer'
const DELETE_BLOCK_LAYER = 'delete_block_layer'
const DELETE_ART_LAYER = 'delete_art_layer'
const SET_LAYER_ROTATION = 'set_layer_rotation'
const SET_BLOCK_LAYER_ROTATION = 'set_block_layer_rotation'
const SET_ART_LAYER_ROTATION = 'set_art_layer_rotation'
const SET_LAYER_Z_AXIS = 'set_layer_z_axis'
const SET_BLOCK_LAYER_Z_AXIS = 'set_block_layer_z_axis'
const SET_ART_LAYER_Z_AXIS = 'set_art_layer_z_axis'
const SET_LAYER_ALPHA = 'set_layer_alpha'
const SET_ART_LAYER_ALPHA = 'set_art_layer_alpha'
const SET_LAYER_DEPTH = 'set_layer_depth'
const SET_ART_LAYER_DEPTH = 'set_art_layer_depth'
const UNDO = 'undo'
const SET_BACKGROUND = 'set_background'
const SET_SONG_ID = 'set_song_id'

var events = []
var redo_events = []
var last_send_event: Dictionary = {}
var game_client: Node2D


func set_game_client(p_game_client) -> void:
	game_client = p_game_client
	game_client.connect("receive_level_event", _on_receive_level_event)


func connect_to(nodes: Array) -> void:
	for node in nodes:
		node.connect("level_event", _on_level_event)


func _on_level_event(event: Dictionary) -> void:
	if event == last_send_event:
		return
		
	last_send_event = event
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	
	if !game_client || !game_client.is_live_editing:
		# Single-player level editor
		emit_signal("level_event", event)
	else:
		# Muti-player level editor
		emit_signal("send_level_event", event)


func _on_receive_level_event(event: Dictionary) -> void:
	print("EditorEvents::_on_receive_level_event ", event)
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
