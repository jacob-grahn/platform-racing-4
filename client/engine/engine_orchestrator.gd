extends Node
class_name EngineOrchestrator

static func init_game_scene(scene: Node) -> void:
	var level_manager: LevelManager = scene.get_node("LevelManager")
	var penciler: Node2D = scene.get_node("Penciler")
	var bg: Node2D = scene.get_node("BG")
	var editor_events: EditorEvents = scene.get_node("EditorEvents")
	var minimap_container = scene.get_node("UI/Minimaps")
	
	Global.layers = level_manager.layers
	Global.minimaps = minimap_container
	Global.bg = bg
	
	var minimap_penciler = preload("res://engine/minimap_penciler.gd").new()
	scene.add_child(minimap_penciler)
	
	editor_events.connect_to([level_manager.level_decoder])
	penciler.init(level_manager.layers, bg, editor_events)
	minimap_penciler.init(level_manager.layers, editor_events, minimap_container)
	
	if !Game.pr2_level_id or Game.pr2_level_id == '0':
		activate_game(scene)
	else:
		print("Game: Loading level id: " + Game.pr2_level_id)
		var http_request = scene.get_node("HTTPRequest")
		http_request.request_completed.connect(func(_result, _response_code, _headers, body):
			var json = JSON.new()
			json.parse(body.get_string_from_utf8())
			var response = json.get_data()
			if !response:
				return
			if response.get("error", ''):
				return
			
			level_manager.decode_level(response, false)
			activate_game(scene)
		)
		if Game.pr2_level_id:
			var error = http_request.request(ApiManager.get_base_url() + "/pr2/level/" + Game.pr2_level_id)
			if error != OK:
				scene.push_error("An error occurred in the HTTP request.")


static func activate_game(scene: Node) -> void:
	var level_manager: LevelManager = scene.get_node("LevelManager")
	var player_manager: PlayerManager = scene.get_node("PlayerManager")
	var minimap_container = scene.get_node("UI/Minimaps")
	
	level_manager.activate_node()
	var character = player_manager.spawn_player(level_manager.layers, level_manager.tiles)
	
	var start_option = Start.get_next_start_option(level_manager.layers)
	for child in minimap_container.get_children():
		child.visible = child.name == start_option.layer_name
	
	level_manager.calc_used_rect()


static func init_tester_scene(scene: Node, data: Dictionary) -> void:
	var level_manager: LevelManager = scene.get_node("LevelManager")
	var penciler: Node2D = scene.get_node("Penciler")
	var bg: Node2D = scene.get_node("BG")
	var editor_events: EditorEvents = scene.get_node("EditorEvents")
	var minimap_container = scene.get_node("UI/Minimaps")
	
	Global.layers = level_manager.layers
	Global.minimaps = minimap_container
	Global.bg = bg
	
	var minimap_penciler = preload("res://engine/minimap_penciler.gd").new()
	scene.add_child(minimap_penciler)
	
	penciler.init(level_manager.layers, bg, editor_events)
	minimap_penciler.init(level_manager.layers, editor_events, minimap_container)
	editor_events.connect_to([level_manager.level_decoder])
	
	var level = data.get("level", {})
	level_manager.decode_level(level, false)
	level_manager.activate_node()
	
	var player_manager: PlayerManager = scene.get_node("PlayerManager")
	var character = player_manager.spawn_player(level_manager.layers, level_manager.tiles)
	
	var start_option = Start.get_next_start_option(level_manager.layers)
	for child in minimap_container.get_children():
		child.visible = child.name == start_option.layer_name
		
	level_manager.calc_used_rect()


static func init_level_editor_scene(scene: Node) -> void:
	var level_manager: LevelManager = scene.get_node("LevelManager")
	var penciler: Node2D = scene.get_node("Penciler")
	var bg: Node2D = scene.get_node("BG")
	var editor_events: EditorEvents = scene.get_node("EditorEvents")
	var cursor: Cursor = scene.get_node("UI/Cursor")
	var editor_menu = scene.get_node("UI/EditorMenu")
	var layer_panel = scene.get_node("UI/LayerPanel")
	var game_client = scene.get_node("/root/Main/GameClient")
	
	Global.ui = scene.get_node("UI")
	Global.game_client = game_client
	Global.editor_events = editor_events
	Global.layers = level_manager.layers
	Global.editor_cursors = scene.get_node("EditorCursorLayer/EditorCursors")
	Global.bg = bg
	Global.layer_panel = layer_panel
	Global.popup_panel = scene.get_node("UI/PopupPanel")
	Global.host_success_panel = scene.get_node("UI/HostSuccessPanel")
	Global.now_editing_panel = scene.get_node("UI/NowEditingPanel")
	Global.editor_explore_button = scene.get_node("UI/Explore")
	Global.editor_load_button = scene.get_node("UI/Load")
	Global.editor_clear_button = scene.get_node("UI/Clear")
	Global.users_host_edit_panel = scene.get_node("UI/HostEditPanel")
	Global.users_join_edit_panel = scene.get_node("UI/JoinEditPanel")
	Global.users_quit_edit_panel = scene.get_node("UI/QuitEditPanel")
	
	editor_events.connect_to([cursor, editor_menu, layer_panel, level_manager.level_decoder])
	editor_events.set_game_client(game_client)
	penciler.init(level_manager.layers, bg, editor_events)
	cursor.init(editor_menu, level_manager.layers)
	
	if LevelEditor.current_level:
		level_manager.decode_level(LevelEditor.current_level, true)
	else:
		var saved_level = FileManager.load_from_file()
		if saved_level:
			level_manager.decode_level(saved_level, true)
		else:
			level_manager.decode_level(scene.default_level, true)
			
	layer_panel.init(level_manager.layers)


static func init_character_editor_scene(scene: Node) -> void:
	var level_manager: LevelManager = scene.get_node("SubViewportContainer/SubViewport/LevelManager")
	var penciler: Node2D = scene.get_node("Penciler")
	var editor_events: EditorEvents = scene.get_node("EditorEvents")
	var cursor: Cursor = scene.get_node("UI/Cursor")
	var editor_menu = scene.get_node("UI/EditorMenu")
	var layer_panel = scene.get_node("UI/LayerPanel")
	
	cursor.init(editor_menu, level_manager.layers)
	editor_events.connect_to([cursor, editor_menu, layer_panel, level_manager.level_decoder])
	penciler.init(level_manager.layers, null, editor_events)
	level_manager.decode_level(scene.default_layers, true)
	layer_panel.init(level_manager.layers)
