extends Node2D

@onready var level_decoder = $LevelDecoder
@onready var back = $Back


func _ready():
	level_decoder.decode(Editor.current_level)
	back.connect("pressed", _on_back_pressed)


func _on_back_pressed():
	Helpers.set_scene(Main.TITLE)
