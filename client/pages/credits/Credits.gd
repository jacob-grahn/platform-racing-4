extends Node2D


func _ready():
	$Back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Helpers.set_scene("TITLE")
