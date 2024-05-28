extends Node2D

@onready var node = $Node
@onready var sprite = $Node/Sprite

func set_tile(atlas: Texture, coords: Vector2i, rotation_rad: float) -> void:
	sprite.rotation = rotation_rad
	sprite.texture = atlas
	sprite.region_rect = Rect2i(coords * Settings.tile_size, Settings.tile_size)
