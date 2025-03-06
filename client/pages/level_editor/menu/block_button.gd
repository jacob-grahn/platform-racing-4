extends Node2D

signal pressed

@onready var button = $Button
@onready var sprite = $Sprite


func _ready():
	button.connect("pressed", _on_pressed)
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(32, 32)


func set_block_id(id: int) -> void:
	var coords = Helpers.to_atlas_coords(id)
	sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)
	

func _on_pressed() -> void:
	emit_signal("pressed")


func get_dimensions() -> Vector2:
	return Vector2(64, 64)
