extends Node2D

var id = ""
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func set_bg(new_id: String) -> void:
	id = new_id
	if id != "":
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % id
		sprite.texture = await CachingLoader.load_texture(url)
		fit_screen.trigger()
