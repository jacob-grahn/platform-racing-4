extends Node2D
class_name Game

static var pr2_level_id
static var game: Game

@onready var back_button = $UI/BackButton
@onready var level_manager: LevelManager = $LevelManager

func _ready():
	back_button.connect("pressed", _on_back_pressed)
	
	Global.layers = $LevelManager.layers
	Global.minimaps = $UI/Minimaps
	Global.bg = $BG
	
	var penciler: Node2D = get_node("Penciler")
	var editor_events: EditorEvents = get_node("EditorEvents")
	var minimap_container = get_node("UI/Minimaps")
	
	var minimap_penciler = preload("res://engine/minimap_penciler.gd").new()
	add_child(minimap_penciler)
	
	editor_events.connect_to([level_manager.level_decoder])
	penciler.init(level_manager.layers, $BG, editor_events)
	minimap_penciler.init(level_manager.layers, editor_events, minimap_container)
	
	if !Game.pr2_level_id or Game.pr2_level_id == '0':
		_activate_game()
	else:
		print("Game: Loading level id: " + Game.pr2_level_id)
		var http_request = get_node("HTTPRequest")
		http_request.request_completed.connect(func(_result, _response_code, _headers, body):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			if !response:
				return
			if response.get("error", ''):
				return
			
			level_manager.decode_level(response, false)
			_activate_game()
		)
		if Game.pr2_level_id:
			var error = http_request.request(ApiManager.get_base_url() + "/pr2/level/" + Game.pr2_level_id)
			if error != OK:
				push_error("An error occurred in the HTTP request.")
	
	Game.game = self


func _activate_game() -> void:
	var player_manager: PlayerManager = get_node("PlayerManager")
	var minimap_container = get_node("UI/Minimaps")
	
	level_manager.activate_node()
	var character = player_manager.spawn_player(level_manager.layers, level_manager.tiles)
	
	var start_option = Start.get_next_start_option(level_manager.layers)
	for child in minimap_container.get_children():
		child.visible = child.name == start_option.layer_name
	
	level_manager.calc_used_rect()


func finish():
	Main.set_scene(Main.TITLE)

func _exit_tree():
	level_manager.clear()
	Game.game = null

func _on_back_pressed():
	Main.set_scene(Main.TITLE)
