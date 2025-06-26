extends IconButton
class_name BlockButton

signal pressed

@onready var tile_texture = preload("res://tiles/tileatlas.png")
var region_sprite: Sprite2D
var sprite_initialized := false


func _ready() -> void:
	super._ready()
	
	# Default colors for block buttons
	active_colors = EditorMenu.COLORS.blocks.active
	inactive_colors = EditorMenu.COLORS.blocks.inactive
	
	# Create a sprite for region support instead of using TextureRect
	texture_rect.visible = false
	
	# Set up the region sprite
	_setup_region_sprite()
	
	# Connect the pressed signal to our own _on_pressed
	texture_button.pressed.disconnect(_pressed)
	texture_button.pressed.connect(_on_pressed)


func _setup_region_sprite() -> void:
	region_sprite = Sprite2D.new()
	region_sprite.texture = tile_texture
	region_sprite.scale = Vector2(0.5, 0.5)
	region_sprite.position = Vector2(32, 32)
	region_sprite.region_enabled = true
	add_child(region_sprite)
	sprite_initialized = true


func set_block_id(id: int) -> void:
	if sprite_initialized:
		var coords = Globals.Helpers.to_atlas_coords(id)
		region_sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)


func _on_pressed() -> void:
	emit_signal("pressed")


# Override the _pressed method to not toggle active state
func _pressed() -> void:
	emit_signal("pressed")
	
	
# Override the render method to update our sprite's color too
func _render() -> void:
	super._render()
	
	# Only update sprite modulate if it's initialized
	if sprite_initialized:
		if active:
			region_sprite.modulate = active_colors.icon
		else:
			region_sprite.modulate = inactive_colors.icon
