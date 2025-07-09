extends Node2D

@onready var back = $UI/Container/Back
@onready var minimap: Minimap = $UI/Container/Minimap
@onready var level_manager: LevelManager = $LevelManager

var current_player_layer: String = ""


func _ready():
	back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)


func get_current_player_layer() -> String:
	return current_player_layer


func init(data: Dictionary):
	var penciler: Node2D = get_node("Penciler")
	var bg: Node2D = get_node("BG")
	var editor_events: EditorEvents = get_node("EditorEvents")
	
	penciler.init(level_manager.layers, bg, editor_events, null)
	editor_events.connect_to([level_manager.level_decoder])
	
	var level = data.get("level", FileManager.load_from_file())
	level_manager.decode_level(level, false)
	level_manager.activate_node()
	
	var start_option = Start.get_next_start_option(level_manager.layers)
	if start_option:
		var player_manager: PlayerManager = get_node("PlayerManager")
		var character = player_manager.spawn_player(level_manager.layers, level_manager.tiles)
		current_player_layer = start_option.layer_name
	
	minimap.init(self)
	level_manager.calc_used_rect()


func finish():
	Main.set_scene(Main.LEVEL_EDITOR)


func _exit_tree():
	level_manager.clear()
