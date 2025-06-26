extends Control
class_name Main

static var FILE_URL = "https://files.platformracing.com"
static var instance: Main

# page names
const TITLE = "TITLE"
const CREDITS = "CREDITS"
const LEVEL_EDITOR = "LEVEL_EDITOR"
const GAME = "GAME"
const LOBBY = "LOBBY"
const SOLO = "SOLO"
const TESTER = "TESTER"
const CHARACTER_EDITOR = "CHARACTER_EDITOR"

var scenes = {
	TITLE: preload("res://pages/title/title.tscn"),
	CREDITS: preload("res://pages/credits/credits.tscn"),
	LEVEL_EDITOR: preload("res://pages/level_editor/level_editor.tscn"),
	GAME: preload("res://pages/game/game.tscn"),
	LOBBY: preload("res://pages/level_lists/lobby.tscn"),
	SOLO: preload("res://pages/solo/solo.tscn"),
	TESTER: preload("res://pages/tester/tester.tscn"),
	CHARACTER_EDITOR: preload("res://pages/character_editor/character_editor.tscn")
}



@onready var game_client: Node2D = $GameClient
var current_scene: Node


func _ready():
	if "--run-tests" in OS.get_cmdline_args():
		Game.pr2_level_id = "50815"
		_set_scene(GAME)
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func(): get_tree().quit())
		return

	Main.instance = self
	set_scene(TITLE)


static func set_scene(scene_name: String) -> Node:
	if !instance:
		return null
	return instance._set_scene(scene_name)


func _set_scene(scene_name: String) -> Node:
	if current_scene:
		current_scene.queue_free()
	current_scene = scenes[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	
	if scene_name == LEVEL_EDITOR:
		game_client._on_connect_editor()
		
	return current_scene
