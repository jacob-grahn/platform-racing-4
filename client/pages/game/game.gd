extends Node2D
class_name Game

static var pr2_level_id
static var game: Game

@onready var back_button = $UI/BackButton
@onready var level_manager: LevelManager = $LevelManager

func _ready():
	back_button.connect("pressed", _on_back_pressed)
	EngineOrchestrator.init_game_scene(self)
	Game.game = self

func finish():
	Main.set_scene(Main.TITLE)

func _exit_tree():
	level_manager.clear()
	Game.game = null

func _on_back_pressed():
	Main.set_scene(Main.TITLE)
