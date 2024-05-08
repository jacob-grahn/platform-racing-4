extends Node2D

const TitlePage = preload("res://pages/title/Title.tscn")
const GamePage = preload("res://pages/game/Game.tscn")
var current_scene: Node2D


func _ready():
	set_scene("TitlePage")


func set_scene(scene_name: String):
	if current_scene:
		current_scene.queue_free()
	current_scene = self[scene_name].instantiate()
	add_child(current_scene)
