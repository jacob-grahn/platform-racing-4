extends Node2D

signal pressed

var base_url = "https://files.platformracing.com/backgrounds"
var max_size = Vector2(64, 64)
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var sprite: Sprite2D = $Sprite
@onready var button = $Button


func _ready():
	button.connect("pressed", _on_pressed)
	http_request.request_completed.connect(_request_completed)


func get_dimensions() -> Vector2:
	return max_size


func set_bg(id: String) -> void:
	var url = base_url + "/" + id + ".jpg"
	http_request.request(url)


func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var image = Image.new()
	var err = image.load_jpg_from_buffer(body)
	if (err):
		print("BackgroundButton::_request_completed error: ", err)
		return
	sprite.texture = ImageTexture.create_from_image(image)
	_resize_sprite()


func _resize_sprite() -> void:
	var size = sprite.texture.get_size()
	var bigger = max(size.x, size.y)
	var target_scale = (max_size / Vector2(bigger, bigger))
	sprite.scale = target_scale


func _on_pressed() -> void:
	emit_signal("pressed")
