extends Control
class_name Main

const CREDITS = preload("res://pages/credits/Credits.tscn")
const EDITOR = preload("res://pages/editor/Editor.tscn")
const GAME = preload("res://pages/game/Game.tscn")
const LOBBY = preload("res://pages/lobby/Lobby.tscn")
const SOLO = preload("res://pages/solo/Solo.tscn")
const TESTER = preload("res://pages/tester/Tester.tscn")
const TITLE = preload("res://pages/title/Title.tscn")

var current_scene: Node


func _ready():
	set_scene("TITLE")


func set_scene(scene_name: String) -> Node:
	if current_scene:
		current_scene.queue_free()
	current_scene = self[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	return current_scene
