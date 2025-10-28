extends Node
class_name Backgrounds

const square = preload("res://engine/bg/100x100.png")
const pr2_field = preload("res://engine/bg/pr2bg1-Field.svg")
const pr2_generic = preload("res://engine/bg/pr2bg2-generic.svg")
const pr2_lake = preload("res://engine/bg/pr2bg3-lake.svg")
const pr2_desert = preload("res://engine/bg/pr2bg4-desert.svg")
const pr2_dots_background = preload("res://engine/bg/pr2bg5-dots-blank.svg")
const pr2_dots_node = preload("res://engine/bg/pr2bg5-dots.tscn")
const pr2_space = preload("res://engine/bg/pr2bg6-space.svg")
const pr2_skyscraper = preload("res://engine/bg/pr2bg7-skyscraper.svg")
const pr3_desert = preload("res://engine/bg/pr3bg1-desert.png")
const pr3_industrial = preload("res://engine/bg/pr3bg2-industrial.png")
const pr3_jungle = preload("res://engine/bg/pr3bg3-jungle.png")
const pr3_space = preload("res://engine/bg/pr3bg4-space.png")
const pr3_underwater = preload("res://engine/bg/pr3bg5-underwater.png")
const pr3_volcano = preload("res://engine/bg/pr3bg6-volcano.png")
const pr3_thanksgiving = preload("res://engine/bg/pr3bg8-thanksgiving.png")
const pr3_main = preload("res://engine/bg/pr3bg9-main.png")
const pr3_christmas = preload("res://engine/bg/pr3bg10-christmas.png")
var bg_list: Array = ["pr2_field", "pr2_generic", "pr2_lake", "pr2_desert", "pr2_dots", "pr2_space", "pr2_skyscraper",
"pr3_desert", "pr3_industrial", "pr3_jungle", "pr3_space", "pr3_underwater", "pr3_volcano", "pr3_thanksgiving", "pr3_main", "pr3_christmas", "blank"]
var bg_graphic_list: Array = [pr2_field, pr2_generic, pr2_lake, pr2_desert, pr2_dots_background, pr2_space, pr2_skyscraper,
pr3_desert, pr3_industrial, pr3_jungle, pr3_space, pr3_underwater, pr3_volcano, pr3_thanksgiving, pr3_main, pr3_christmas]
# ^ this is for level editor ^
var bg_failsafe_list: Array = ["field", "generic", "lake", "desert", "dots", "space", "skyscraper"]

func set_dots(sprite: Sprite2D):
	# dots colors are random, has entire system dedicated to that.
	if !sprite.has_node("Dots"):
		sprite.texture = pr2_dots_background
		sprite.set_region_enabled(false)
		var dots = pr2_dots_node.instantiate()
		sprite.add_child(dots)

func get_bg(sprite: Sprite2D, p_id: String, fade_color: Color, load_from_url: bool = false) -> void:
	var background_id = p_id
	# deletes the dots if id isn't dots so we don't keep making more dots
	if (background_id != "dots" or background_id != "pr2_dots") and sprite.has_node("Dots"):
		sprite.get_node("Dots").queue_free()
	# loads backgrounds from the website api if load_from_url is true.
	# disabled as we want the backgrounds to be in game for level editor.
	if load_from_url:
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % background_id
		sprite.texture = await CachingLoader.load_texture(url)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	elif background_id in bg_list or background_id in bg_failsafe_list:
		match background_id:
			# sets backgrounds accordingly
			# the ids without the "pr2_" prefixes are failsafes for old levels.
			"blank": sprite.texture = square
			"field", "pr2_field", "pr3_field": sprite.texture = pr2_field; sprite.set_region_enabled(false)
			"generic", "pr2_generic": sprite.texture = pr2_generic; sprite.set_region_enabled(false)
			"lake", "pr2_lake": sprite.texture = pr2_lake; sprite.set_region_enabled(false)
			"desert", "pr2_desert": sprite.texture = pr2_desert; sprite.set_region_enabled(true); sprite.set_region_rect(Rect2(3.0, 0.0, 550.0, 400.0))
			"dots", "pr2_dots": set_dots(sprite)
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
		if background_id == "blank":
			sprite.modulate = fade_color
		else:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		sprite.texture = pr2_field; sprite.set_region_enabled(false)
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
