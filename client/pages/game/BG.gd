extends Node2D

var base_url = "https://files.platformracing.com/backgrounds"
var id = ""
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func _ready() -> void:
	http_request.request_completed.connect(_request_completed)


func set_bg(bg_id: String) -> void:
	id = bg_id
	if id != "":
		var url = base_url + "/" + id + ".jpg"
		http_request.request(url)


func _request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var image = Image.new()
	var err = image.load_jpg_from_buffer(body)
	if (err):
		print("BG::_request_completed error: ", err)
		return
	sprite.texture = ImageTexture.create_from_image(image)
	fit_screen.trigger()
