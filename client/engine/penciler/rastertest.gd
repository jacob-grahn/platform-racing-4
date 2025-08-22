extends Node2D

@onready var bg = $Background
var image = Image.new()
var image_texture = ImageTexture.new()


func _ready() -> void:
	image.create_empty(1920, 1080, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 0.5))
	image_texture.create_from_image(image)
	bg.texture = image_texture
