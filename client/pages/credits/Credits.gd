extends Node2D


func _ready():
	$Back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Main.set_scene(Main.TITLE)
