extends Node2D

signal pressed

# list already exists in bg, this could probably be handled better.
var pr2_field = preload("res://engine/bg/PR2BG1-Field.svg")
var pr2_generic = preload("res://engine/bg/PR2BG2-Generic.svg")
var pr2_lake = preload("res://engine/bg/PR2BG3-Lake.svg")
var pr2_desert = preload("res://engine/bg/PR2BG4-Desert.svg")
var pr2_dots = preload("res://engine/bg/PR2BG5DotsBlank.svg")
var pr2_space = preload("res://engine/bg/PR2BG6-Space.svg")
var pr2_skyscraper = preload("res://engine/bg/PR2BG7-Skyscraper.svg")
var pr3_desert = preload("res://engine/bg/PR3BG1-Desert.png")
var pr3_industrial = preload("res://engine/bg/PR3BG2-Industrial.png")
var pr3_jungle = preload("res://engine/bg/PR3BG3-Jungle.png")
var pr3_space = preload("res://engine/bg/PR3BG4-Space.png")
var pr3_underwater = preload("res://engine/bg/PR3BG5-Underwater.png")
var pr3_volcano = preload("res://engine/bg/PR3BG6-Volcano.png")
var pr3_thanksgiving = preload("res://engine/bg/PR3BG8-Thanksgiving.png")
var pr3_main = preload("res://engine/bg/PR3BG9-Main.png")
var pr3_christmas = preload("res://engine/bg/PR3BG10-Christmas.png")
var max_size = Vector2(64, 64)
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var sprite: Sprite2D = $Sprite
@onready var button = $Button


func _ready():
	button.connect("pressed", _on_pressed)


func get_dimensions() -> Vector2:
	return max_size


func set_bg(id: String) -> void:
	# var url = "https://files.platformracing.com/backgrounds/%s.jpg" % id
	# sprite.texture = await CachingLoader.load_texture(url)
	match id:
			# this really could've been done better.
			"field", "pr2_field", "pr3_field": sprite.texture = pr2_field
			"generic", "pr2_generic": sprite.texture = pr2_generic
			"lake", "pr2_lake": sprite.texture = pr2_lake
			"desert", "pr2_desert": sprite.texture = pr2_desert
			"dots", "pr2_dots": sprite.texture = pr2_dots
			"space", "pr2_space": sprite.texture = pr2_space
			"skyscraper", "pr2_skyscraper": sprite.texture = pr2_skyscraper
			"pr3_desert": sprite.texture = pr3_desert
			"pr3_industrial": sprite.texture = pr3_industrial
			"pr3_jungle": sprite.texture = pr3_jungle
			"pr3_space": sprite.texture = pr3_space
			"pr3_underwater": sprite.texture = pr3_underwater
			"pr3_volcano": sprite.texture = pr3_volcano
			"pr3_thanksgiving": sprite.texture = pr3_thanksgiving
			"pr3_main": sprite.texture = pr3_main
			"pr3_christmas": sprite.texture = pr3_christmas
	_resize_sprite()


func _resize_sprite() -> void:
	var size = sprite.texture.get_size()
	var bigger = max(size.x, size.y)
	var target_scale = (max_size / Vector2(bigger, bigger))
	sprite.scale = target_scale


func _on_pressed() -> void:
	emit_signal("pressed")
