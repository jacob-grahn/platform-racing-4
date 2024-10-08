extends SliderRow

signal level_event

const BACKGROUND_BUTTON: PackedScene = preload("res://pages/editor/menu/BackgroundButton.tscn")


func _ready():
	super._ready()
	
	# Add background buttons
	var bg_list = [
		'desert',
		'dots',
		'field',
		'generic',
		'lake',
		'skyscraper',
		'space'
	]
	for id in bg_list:
		var bg_button = BACKGROUND_BUTTON.instantiate()
		add_slider(bg_button)
		bg_button.set_bg(id)
		bg_button.pressed.connect(_click_bg.bind(id))


func _click_bg(bg_id: String):
	print("clicked ", bg_id)
	emit_signal("level_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": bg_id
	})
