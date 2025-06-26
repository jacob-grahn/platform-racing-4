extends Node2D
class_name LevelEditor

static var current_level: Dictionary
static var current_level_description: String

var tiles: Tiles = Tiles.new()
var default_level: Dictionary = {
	"layers": [{
		"name": "Layer 1",
		"chunks": [],
		"rotation": 0,
		"depth": 10
	}]
}
@onready var layers = $Layers
@onready var level_encoder = $LevelEncoder
@onready var level_decoder = $LevelDecoder
@onready var game_client = get_node("/root/Main/GameClient")
@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var explore = $UI/Explore
@onready var load = $UI/Load
@onready var save = $UI/Save
@onready var clear = $UI/Clear
@onready var editor_menu = $UI/EditorMenu
@onready var layer_panel = $UI/LayerPanel
@onready var save_panel = $UI/SavePanel
@onready var load_panel = $UI/LoadPanel
@onready var explore_panel = $UI/ExplorePanel
@onready var confirm_delete_panel = $UI/ConfirmDeletePanel
@onready var cursor: Cursor = $UI/Cursor
@onready var http_request = $HTTPRequest
@onready var editor_events: EditorEvents = $EditorEvents
@onready var penciler: Node2D = $Penciler
@onready var editor_camera: Camera2D = $EditorCamera
@onready var now_editing_panel: Node2D = $UI/NowEditingPanel
@onready var bg: Node2D = $BG


func _ready():
	Global.ui = $UI
	Global.game_client = get_node("/root/Main/GameClient")
	Global.editor_events = $EditorEvents
	Global.layers = $Layers
	Global.editor_cursors = $EditorCursorLayer/EditorCursors
	Global.bg = $BG
	Global.layer_panel = $UI/LayerPanel
	Global.popup_panel = $UI/PopupPanel
	Global.host_success_panel = $UI/HostSuccessPanel
	Global.now_editing_panel = $UI/NowEditingPanel
	Global.editor_explore_button = $UI/Explore
	Global.editor_load_button = $UI/Load
	Global.editor_clear_button = $UI/Clear
	Global.users_host_edit_panel = $UI/HostEditPanel
	Global.users_join_edit_panel = $UI/JoinEditPanel
	Global.users_quit_edit_panel = $UI/QuitEditPanel
	Jukebox.play("noodletown-4-remake")
	back.connect("pressed", _on_back_pressed)
	explore.connect("pressed", _on_explore_pressed)
	load.connect("pressed", _on_load_pressed)
	save.connect("pressed", _on_save_pressed)
	test.connect("pressed", _on_test_pressed)
	clear.connect("pressed", _on_clear_pressed)
	load_panel.connect("level_load", _on_level_load)
	explore_panel.connect("explore_load", _on_explore_load)
	game_client.connect("request_editor_load", _on_request_editor_load)
	
	tiles.init_defaults()
	layers.init(tiles)
	editor_events.connect_to([cursor, editor_menu, layer_panel, level_decoder])
	editor_events.set_game_client(game_client)
	penciler.init(layers, bg, editor_events)
	cursor.init(editor_menu, layers)
	now_editing_panel.init(editor_menu)
	editor_camera.target_zoom = 0.5
	editor_camera.change_camera_zoom(0.5)
	
	# Connect control events for camera zoom changes
	editor_menu.control_event.connect(_on_control_event)

	if LevelEditor.current_level:
		level_decoder.decode(LevelEditor.current_level, true, layers)
	else:
		var saved_level = FileManager.load_from_file()
		if saved_level:
			level_decoder.decode(saved_level, true, layers)
		else:
			level_decoder.decode(default_level, true, layers)

	layer_panel.init(layers)
	Jukebox.end_music = true


func _on_back_pressed():
	LevelEditor.current_level = level_encoder.encode()
	FileManager.save_to_file(LevelEditor.current_level)
	await Main.set_scene(Main.TITLE)


func _on_explore_pressed():
	save_panel.close()
	load_panel.close()
	confirm_delete_panel.close()
	explore_panel.initialize()


func _on_load_pressed():
	explore_panel.close()
	save_panel.close()
	confirm_delete_panel.close()
	load_panel.initialize()


func _on_save_pressed():
	LevelEditor.current_level = level_encoder.encode()
	explore_panel.close()
	load_panel.close()
	confirm_delete_panel.close()
	save_panel.initialize(LevelEditor.current_level)


func _on_test_pressed():
	LevelEditor.current_level = level_encoder.encode()
	FileManager.save_to_file(LevelEditor.current_level)
	await Main.set_scene(Main.TESTER, { "level": LevelEditor.current_level })


func _on_clear_pressed():
	save_panel.close()
	load_panel.close()
	explore_panel.close()
	confirm_delete_panel.initialize(self, "clear")


func _on_level_load(level_name = ""):
	FileManager.set_current_level_name(level_name)
	
	var selected_level = default_level
	if (level_name != ""):
		selected_level = FileManager.load_from_file(level_name)
		
	layers.clear()
	tiles.clear()
	LevelEditor.current_level = selected_level
	await get_tree().create_timer(0.1).timeout
	level_decoder.decode(selected_level, true, layers)
	layers.init(tiles)


func _on_request_editor_load():
	FileManager.set_current_level_name("")
	layers.clear()
	tiles.clear()
	await get_tree().create_timer(0.1).timeout
	level_decoder.decode(LevelEditor.current_level, true, layers)
	layers.init(tiles)


func _on_explore_load(level_id):
	var url = ApiManager.get_base_url() + "/level/" + str(level_id)
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		return

	$HTTPRequest.request_completed.connect(_on_explore_load_completed)


func _on_explore_load_completed(result, response_code, _headers, body):
	if result != OK or response_code != 200:
		push_error("Failed to fetch level.")
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		print("No data received for level.")
		return
	
	var level_name = response.get("level_name", "")
	var level_data = response.get("level_data", "")
	
	level_data = Marshalls.base64_to_utf8(level_data)
	level_data = JSON.parse_string(level_data)
	FileManager.set_current_level_name(level_name)

	layers.clear()
	tiles.clear()
	LevelEditor.current_level = level_data
	await get_tree().create_timer(0.1).timeout
	level_decoder.decode(LevelEditor.current_level, true, layers)
	layers.init(tiles)


func _on_control_event(event: Dictionary) -> void:
	if event.get("type") == "editor_camera_zoom_change":
		var zoom_value = event.get("zoom")
		if zoom_value:
			editor_camera.change_camera_zoom(zoom_value)
