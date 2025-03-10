extends Node2D

signal pressed

@onready var button = $Button
@onready var sprite = $Sprite
@onready var background = $Background

var active = false


func _ready():
	button.connect("pressed", _on_pressed)
	sprite.scale = Vector2(0.5, 0.5)
	sprite.position = Vector2(32, 32)
	
	# Make sure the background node exists
	if not has_node("Background"):
		background = ColorRect.new()
		background.name = "Background"
		background.size = Vector2(64, 64)
		background.color = Color(1, 1, 1, 1)
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(background)
		move_child(background, 0)  # Move to back
	
	# Initially set inactive
	set_active(false)


func set_block_id(id: int) -> void:
	var coords = Helpers.to_atlas_coords(id)
	sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)
	

func _on_pressed() -> void:
	emit_signal("pressed")


func get_dimensions() -> Vector2:
	return Vector2(64, 64)


func set_active(is_active: bool) -> void:
	active = is_active
	
	if active:
		# Active state: blue background, white sprite
		if background:
			background.color = Color("2a9fd6")  # Light blue
		sprite.modulate = Color(1, 1, 1, 1)  # White
	else:
		# Inactive state: white background, blue sprite
		if background:
			background.color = Color(1, 1, 1, 1)  # White
		sprite.modulate = Color(1, 1, 1, 1)  # No tint
