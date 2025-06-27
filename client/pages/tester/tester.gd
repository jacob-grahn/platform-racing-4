extends Node2D

@onready var back = $UI/Back
@onready var level_manager: LevelManager = $LevelManager

func _ready():
	Global.layers = level_manager.layers
	Global.minimaps = $UI/Minimaps
	Global.bg = $BG
	back.connect("pressed", _on_back_pressed)
	Jukebox.play("pr1-future-penumbra")

func _on_back_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)

func init(data: Dictionary):
	EngineOrchestrator.init_tester_scene(self, data)

func finish():
	Main.set_scene(Main.LEVEL_EDITOR)

func _exit_tree():
	level_manager.clear()
