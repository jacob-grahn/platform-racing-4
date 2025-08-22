extends SliderRow

signal level_event

const BACKGROUND_BUTTON: PackedScene = preload("res://mega_menu/background_button.tscn")
const BACKGROUND_IDS := ["pr2_field", "pr2_generic", "pr2_lake", "pr2_desert", "pr2_dots", "pr2_space", "pr2_skyscraper", "pr3_desert", "pr3_industrial", "pr3_jungle", "pr3_space", "pr3_underwater", "pr3_volcano", "pr3_thanksgiving", "pr3_main", "pr3_christmas"]

func _ready():
	super._ready()
	
	# Add background buttons
	for id in BACKGROUND_IDS:
		var bg_button = BACKGROUND_BUTTON.instantiate()
		add_slider(bg_button)
		bg_button.set_bg(id)
		bg_button.pressed.connect(_click_bg.bind(id))


func _click_bg(bg_id: String):
	emit_signal("level_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": bg_id,
		"fade_color": "FFFFFF"
	})
