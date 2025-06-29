extends Node2D

@onready var back = $UI/Back
@onready var level_manager: LevelManager = $LevelManager

func _ready():
	Global.minimaps = $UI/Minimaps
	back.connect("pressed", _on_back_pressed)
  # Jukebox.play("pr1-future-penumbra")

func _on_back_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)

func init(data: Dictionary):
	var penciler: Node2D = get_node("Penciler")
	var bg: Node2D = get_node("BG")
	var editor_events: EditorEvents = get_node("EditorEvents")
	var minimap_container = get_node("UI/Minimaps")
	
	var minimap_penciler = preload("res://engine/minimap_penciler.gd").new()
	add_child(minimap_penciler)
	
	penciler.init(level_manager.layers, bg, editor_events, null)
	minimap_penciler.init(level_manager.layers, editor_events, minimap_container)
	editor_events.connect_to([level_manager.level_decoder])
	
	var level = data.get("level", FileManager.load_from_file())
	level_manager.decode_level(level, false)
	level_manager.activate_node()
	
	var start_option = Start.get_next_start_option(level_manager.layers)
	if start_option:
		var player_manager: PlayerManager = get_node("PlayerManager")
		var character = player_manager.spawn_player(level_manager.layers, level_manager.tiles)
		for child in minimap_container.get_children():
			child.visible = child.name == start_option.layer_name
		
	level_manager.calc_used_rect()


func finish():
	Main.set_scene(Main.LEVEL_EDITOR)

func _exit_tree():
	level_manager.clear()
