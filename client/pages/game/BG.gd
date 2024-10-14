extends Node2D

var id = ""
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func set_bg(new_id: String) -> void:
	id = new_id
	if id != "":
		sprite.texture = await BackgroundsLoader.get_background(id)
		fit_screen.trigger()
