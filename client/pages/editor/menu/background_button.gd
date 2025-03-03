extends Node2D

signal pressed

var max_size = Vector2(64, 64)
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var sprite: Sprite2D = $Sprite
@onready var button = $Button


func _ready():
	button.connect("pressed", _on_pressed)


func get_dimensions() -> Vector2:
	return max_size


func set_bg(id: String) -> void:
	var url = "https://files.platformracing.com/backgrounds/%s.jpg" % id
	sprite.texture = await CachingLoader.load_texture(url)
	_resize_sprite()


func _resize_sprite() -> void:
	var size = sprite.texture.get_size()
	var bigger = max(size.x, size.y)
	var target_scale = (max_size / Vector2(bigger, bigger))
	sprite.scale = target_scale


func _on_pressed() -> void:
	emit_signal("pressed")
