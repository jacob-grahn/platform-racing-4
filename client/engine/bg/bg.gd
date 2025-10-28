extends Node2D
class_name Background

var id = ""
var fade_color = Color("FFFFFFFF")
var song_id: String = "random"
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func set_bg(p_id: String, p_fade_color: Color) -> void:
	id = p_id
	fade_color = p_fade_color
	var backgrounds = Backgrounds.new()
	backgrounds.get_bg(sprite, id, fade_color)
	fit_screen.trigger()


func set_song_id(new_song_id: String) -> void:
	song_id = new_song_id
