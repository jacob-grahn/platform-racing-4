extends Node

var character: Node2D
var spawn: Node
var ui: Node
var game_client: Node
var editor_events: Node
var layers: Node
var editor_cursors: Node
var minimaps: Node
var tile_map: Node
var bg: Node
var layer_panel: Node
var popup_panel: Node
var host_success_panel: Node
var now_editing_panel: Node
var editor_explore_button: Node
var editor_load_button: Node
var editor_clear_button: Node
var users_host_edit_panel: Node
var users_join_edit_panel: Node
var users_quit_edit_panel: Node
var item_holder: Node

func clear():
	character = null
	spawn = null
	ui = null
	game_client = null
	editor_events = null
	layers = null
	editor_cursors = null
	minimaps = null
	tile_map = null
	bg = null
	layer_panel = null
	popup_panel = null
	host_success_panel = null
	now_editing_panel = null
	editor_explore_button = null
	editor_load_button = null
	editor_clear_button = null
	users_host_edit_panel = null
	users_join_edit_panel = null
	users_quit_edit_panel = null
	item_holder = null
