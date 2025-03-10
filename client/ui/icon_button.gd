extends Node2D
class_name IconButton

const dimensions = Vector2(64, 64)
var active = false
var active_colors = {
	"bg": Color("000000"),
	"icon": Color("FFFFFF")
}
var inactive_colors = {
	"bg": Color("FFFFFF"),
	"icon": Color("000000")
}

@onready var texture_button: TextureButton = $TextureButton
@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	texture_button.pressed.connect(_pressed)


func init(texture: Texture2D, p_active_colors: Dictionary, p_inactive_colors: Dictionary) -> void:
	active_colors = p_active_colors.duplicate()
	inactive_colors = p_inactive_colors.duplicate()
	
	# Set the texture
	texture_rect.texture = texture
	_render()


func set_active(p_active: bool) -> void:
	active = p_active
	_render()


func get_dimensions() -> Vector2:
	return dimensions


func _pressed() -> void:
	active = !active
	_render()


func _render() -> void:
	var colors = inactive_colors
	if active:
		colors = active_colors
	
	color_rect.color = colors.bg
	texture_rect.modulate = colors.icon
	
	var texture_size_actual = texture_rect.texture.get_size()
	texture_rect.scale = Vector2(dimensions.x / texture_size_actual.x, dimensions.y / texture_size_actual.y)
