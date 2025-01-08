extends Control
class_name Main

static var FILE_URL = "https://files.platformracing.com"
const CREDITS = preload("res://pages/credits/Credits.tscn")
const EDITOR = preload("res://pages/editor/Editor.tscn")
const GAME = preload("res://pages/game/Game.tscn")
const LOBBY = preload("res://pages/level_lists/Lobby.tscn")
const SOLO = preload("res://pages/solo/Solo.tscn")
const TESTER = preload("res://pages/tester/Tester.tscn")
const TITLE = preload("res://pages/title/Title.tscn")

@onready var game_client: Node2D = $GameClient
var current_scene: Node


func _ready():
	set_scene("TITLE")


func set_scene(scene_name: String) -> Node:
	Session.set_current_scene_name(scene_name)
	
	if current_scene:
		current_scene.queue_free()
	current_scene = self[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	
	if scene_name == "EDITOR":
		game_client._on_connect_editor()
		
	return current_scene
