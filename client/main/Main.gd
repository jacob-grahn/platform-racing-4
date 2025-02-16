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
	TITLE: preload("res://pages/title/Title.tscn"),
	CREDITS: preload("res://pages/credits/Credits.tscn"),
	LEVEL_EDITOR: preload("res://pages/editor/level_editor.tscn"),
	GAME: preload("res://pages/game/Game.tscn"),
	LOBBY: preload("res://pages/level_lists/Lobby.tscn"),
	SOLO: preload("res://pages/solo/Solo.tscn"),
	TESTER: preload("res://pages/tester/Tester.tscn"),
	CHARACTER_EDITOR: preload("res://pages/editor/character_editor.tscn")
}



@onready var game_client: Node2D = $GameClient
var current_scene: Node


func _ready():
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
