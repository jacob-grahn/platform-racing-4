extends SliderRow

signal level_event

const BACKGROUND_BUTTON: PackedScene = preload("res://mega_menu/background_button.tscn")
const BACKGROUND_IDS := ["field", "desert", "dots", "generic", "lake", "skyscraper", "space"]

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
		"bg": bg_id
	})
