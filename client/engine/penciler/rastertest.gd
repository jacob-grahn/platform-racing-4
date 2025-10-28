extends Node2D

@onready var bg = $Background
@onready var cursor = $Cursor
var image = Image.new() #.load_from_file("res://stamps/CactusGraphic.svg")


func _ready() -> void:
	bg.texture = ImageTexture.new()
	image = Image.create_empty(1920, 1080, false, Image.FORMAT_RGBA8)
	#image.fill(Color("FFFFFFFF"))
	#image.set_pixel(60, 60, Color.RED)
	bg.texture.set_image(image)
	global_position = Vector2(image.get_width() / 2, image.get_height() / 2)

func _process(delta: float) -> void:
	cursor.global_position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		image.set_pixel(int(cursor.global_position.x), int(cursor.global_position.y), Color.RED)
	bg.texture.update(image)
