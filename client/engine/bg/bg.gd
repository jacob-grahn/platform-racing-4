extends Node2D

const square = preload("res://engine/bg/100x100.png")
const pr2_field = preload("res://engine/bg/PR2BG1-Field.svg")
const pr2_generic = preload("res://engine/bg/PR2BG2-Generic.svg")
const pr2_lake = preload("res://engine/bg/PR2BG3-Lake.svg")
const pr2_desert = preload("res://engine/bg/PR2BG4-Desert.svg")
const pr2_dots_background = preload("res://engine/bg/PR2BG5DotsBlank.svg")
const pr2_dots_node = preload("res://engine/bg/PR2BG5Dots.tscn")
const pr2_space = preload("res://engine/bg/PR2BG6-Space.svg")
const pr2_skyscraper = preload("res://engine/bg/PR2BG7-Skyscraper.svg")
const pr3_desert = preload("res://engine/bg/PR3BG1-Desert.png")
const pr3_industrial = preload("res://engine/bg/PR3BG2-Industrial.png")
const pr3_jungle = preload("res://engine/bg/PR3BG3-Jungle.png")
const pr3_space = preload("res://engine/bg/PR3BG4-Space.png")
const pr3_underwater = preload("res://engine/bg/PR3BG5-Underwater.png")
const pr3_volcano = preload("res://engine/bg/PR3BG6-Volcano.png")
const pr3_thanksgiving = preload("res://engine/bg/PR3BG8-Thanksgiving.png")
const pr3_main = preload("res://engine/bg/PR3BG9-Main.png")
const pr3_christmas = preload("res://engine/bg/PR3BG10-Christmas.png")
var id = ""
var load_from_url: bool = false
@onready var sprite: Sprite2D = $Sprite
@onready var fit_screen: Node2D = $Sprite/FitScreen


func set_dots():
	# dots colors are random, has entire system dedicated to that.
	if (id == "dots" or id == "pr2_dots") and !sprite.has_node("Dots"):
		sprite.texture = pr2_dots_background
		sprite.set_region_enabled(false)
		var dots = pr2_dots_node.instantiate()
		sprite.add_child(dots)

func set_bg(p_id: String, fade_color: Color) -> void:
	id = p_id
	# deletes the dots if id isn't dots so we don't keep making more dots
	if (id != "dots" or id != "pr2_dots") and sprite.has_node("Dots"):
		sprite.get_node("Dots").queue_free()
	# loads backgrounds from the website api if load_from_url is true.
	# disabled at the moment but could be used for web version,
	# though the bgs only take up a couple of bytes.
	if load_from_url:
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % id
		sprite.texture = await CachingLoader.load_texture(url)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		match id:
			# sets backgrounds accordingly
			# the ids without the "pr2_" prefixes are failsafes for old levels.
			"blank": sprite.texture = square
			"field", "pr2_field", "pr3_field": sprite.texture = pr2_field; sprite.set_region_enabled(false)
			"generic", "pr2_generic": sprite.texture = pr2_generic; sprite.set_region_enabled(false)
			"lake", "pr2_lake": sprite.texture = pr2_lake; sprite.set_region_enabled(false)
			"desert", "pr2_desert": sprite.texture = pr2_desert; sprite.set_region_enabled(true); sprite.set_region_rect(Rect2(3.0, 0.0, 550.0, 400.0))
			"dots", "pr2_dots": set_dots()
			"space", "pr2_space": sprite.texture = pr2_space; sprite.set_region_enabled(true); sprite.set_region_rect(Rect2(22.0, 0.0, 550.0, 400.0))
			"skyscraper", "pr2_skyscraper": sprite.texture = pr2_skyscraper; sprite.set_region_enabled(true); sprite.set_region_rect(Rect2(48.0, 0.0, 550.0, 400.0))
			"pr3_desert": sprite.texture = pr3_desert; sprite.set_region_enabled(false)
			"pr3_industrial": sprite.texture = pr3_industrial; sprite.set_region_enabled(false)
			"pr3_jungle": sprite.texture = pr3_jungle; sprite.set_region_enabled(false)
			"pr3_space": sprite.texture = pr3_space; sprite.set_region_enabled(false)
			"pr3_underwater": sprite.texture = pr3_underwater; sprite.set_region_enabled(false)
			"pr3_volcano": sprite.texture = pr3_volcano; sprite.set_region_enabled(false)
			"pr3_thanksgiving": sprite.texture = pr3_thanksgiving; sprite.set_region_enabled(false)
			"pr3_main": sprite.texture = pr3_main; sprite.set_region_enabled(false)
			"pr3_christmas": sprite.texture = pr3_christmas; sprite.set_region_enabled(false)
			_: sprite.texture = pr2_field; sprite.set_region_enabled(false)
		if id == "blank":
			sprite.modulate = fade_color
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	fit_screen.trigger()
