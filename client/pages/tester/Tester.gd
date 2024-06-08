extends Node2D

@onready var level_decoder = $LevelDecoder
@onready var back = $Back


func _ready():
	back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Helpers.set_scene("EDITOR")


func set_level(level: Dictionary) -> void:
	level_decoder.decode(level)
