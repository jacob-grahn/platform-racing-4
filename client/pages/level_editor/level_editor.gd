extends Node2D
class_name LevelEditor

static var current_level: Dictionary
static var current_level_description: String

var default_level: Dictionary = {
	"layers": [{
		"name": "Layer 1",
		"chunks": [],
		"rotation": 0,
		"depth": 10
	}]
}
@onready var level_manager: LevelManager = $LevelManager
@onready var game_client = get_node("/root/Main/GameClient")
@onready var back = $UI/Back
@onready var test = $UI/Test
@onready var explore = $UI/Explore
@onready var load = $UI/Load
@onready var save = $UI/Save
@onready var clear = $UI/Clear
@onready var layer_panel = $UI/LayerPanel
@onready var save_panel = $UI/SavePanel
@onready var load_panel = $UI/LoadPanel
@onready var explore_panel = $UI/ExplorePanel
@onready var confirm_delete_panel = $UI/ConfirmDeletePanel
@onready var http_request = $HTTPRequest
@onready var editor_camera: Camera2D = $EditorCamera
@onready var now_editing_panel: Node2D = $UI/NowEditingPanel


func init(data: Dictionary = {}):
	_on_connect_editor()


func _ready():
	tree_exiting.connect(_on_disconnect_editor)
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
	
	EngineOrchestrator.init_level_editor_scene(self)
	
	editor_camera.target_zoom = 0.5
	editor_camera.change_camera_zoom(0.5)
	
	# Connect control events for camera zoom changes
	$UI/EditorMenu.control_event.connect(_on_control_event)
	now_editing_panel.init($UI/EditorMenu)
	Jukebox.end_music = true


func _on_back_pressed():
	LevelEditor.current_level = level_manager.encode_level()
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
	LevelEditor.current_level = level_manager.encode_level()
	explore_panel.close()
	load_panel.close()
	confirm_delete_panel.close()
	save_panel.initialize(LevelEditor.current_level)


func _on_test_pressed():
	LevelEditor.current_level = level_manager.encode_level()
	FileManager.save_to_file(LevelEditor.current_level)
	Main.set_scene(Main.TESTER, { "level": LevelEditor.current_level })


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
		
	level_manager.clear()
	LevelEditor.current_level = selected_level
	await get_tree().create_timer(0.1).timeout
	level_manager.decode_level(selected_level, true)
	level_manager.layers.init(level_manager.tiles)


func _on_request_editor_load():
	FileManager.set_current_level_name("")
	level_manager.clear()
	await get_tree().create_timer(0.1).timeout
	level_manager.decode_level(LevelEditor.current_level, true)
	level_manager.layers.init(level_manager.tiles)


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

	level_manager.clear()
	LevelEditor.current_level = level_data
	await get_tree().create_timer(0.1).timeout
	level_manager.decode_level(LevelEditor.current_level, true)
	level_manager.layers.init(level_manager.tiles)


func _on_control_event(event: Dictionary) -> void:
	if event.get("type") == "editor_camera_zoom_change":
		var zoom_value = event.get("zoom")
		if zoom_value:
			editor_camera.change_camera_zoom(zoom_value)


func _on_connect_editor() -> void:
	$EditorEvents.connect("send_level_event", game_client._on_send_level_event)


func _on_disconnect_editor() -> void:
	if $EditorEvents:
		$EditorEvents.disconnect("send_level_event", game_client._on_send_level_event)
	
	Global.popup_panel = null
	Global.host_success_panel = null
	Global.editor_events = null
	Global.now_editing_panel = null
	Global.layers = null
	Global.editor_cursors = null
	Global.editor_explore_button = null
	Global.editor_load_button = null
	Global.editor_clear_button = null
	
	if !game_client.isFirstOpenEditor:
		var data_room = {
			"module": "RequestRoomModule",
			"id": Session.get_username(),
			"ms": 5938,
			"room" : game_client.room,
			"ret": true,
		}
		game_client.send_queue.push_back(data_room)
	
	game_client.isFirstOpenEditor = false
	if Global.editor_cursors:
		Global.editor_cursors.add_new_cursor(Session.get_username())
	game_client.toggle_editor_buttons(game_client.is_live_editing)
