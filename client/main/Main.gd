extends Node2D
class_name Main


const TITLE = preload("res://pages/title/Title.tscn")
const GAME = preload("res://pages/game/Game.tscn")
const EDITOR = preload("res://pages/editor/Editor.tscn")
const TESTER = preload("res://pages/tester/Tester.tscn")

var current_scene: Node2D


func _ready():
	set_scene("TITLE")


func set_scene(scene_name: String) -> Node2D:
	if current_scene:
		current_scene.queue_free()
	current_scene = self[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	return current_scene
