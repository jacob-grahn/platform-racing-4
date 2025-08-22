extends IconButton

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

var default_texture = load("res://icon.svg")
var colors = {
	"bg": Color("ffffff"),
	"icon": Color("ffffff")
}
var editor_events: Node2D

	
func _ready() -> void:
	if LevelEditor.level_editor:
		editor_events = LevelEditor.level_editor.get_node("EditorEvents")
		editor_events.level_event.connect(_level_event)
	init(default_texture, colors, colors)


func _level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_BACKGROUND:
		# var url = "https://files.platformracing.com/backgrounds/%s.jpg" % event.bg
		# texture_rect.texture = await CachingLoader.load_texture(url)
		match event.bg:
			# this really could've been done better.
			"field", "pr2_field", "pr3_field": texture_rect.texture = pr2_field
			"generic", "pr2_generic": texture_rect.texture = pr2_generic
			"lake", "pr2_lake": texture_rect.texture = pr2_lake
			"desert", "pr2_desert": texture_rect.texture = pr2_desert
			"dots", "pr2_dots": texture_rect.texture = pr2_dots
			"space", "pr2_space": texture_rect.texture = pr2_space
			"skyscraper", "pr2_skyscraper": texture_rect.texture = pr2_skyscraper
			"pr3_desert": texture_rect.texture = pr3_desert
			"pr3_industrial": texture_rect.texture = pr3_industrial
			"pr3_jungle": texture_rect.texture = pr3_jungle
			"pr3_space": texture_rect.texture = pr3_space
			"pr3_underwater": texture_rect.texture = pr3_underwater
			"pr3_volcano": texture_rect.texture = pr3_volcano
			"pr3_thanksgiving": texture_rect.texture = pr3_thanksgiving
			"pr3_main": texture_rect.texture = pr3_main
			"pr3_christmas": texture_rect.texture = pr3_christmas
			_: texture_rect.texture =  default_texture
	_render()
