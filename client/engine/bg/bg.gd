extends Node2D

const square = preload("res://engine/bg/100x100.png")
var id = ""
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func set_bg(p_id: String, fade_color: Color) -> void:
	id = p_id
	if id == "blank":
		sprite.texture = square
		sprite.modulate = fade_color
	else:
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % id
		sprite.texture = await CachingLoader.load_texture(url)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	fit_screen.trigger()
