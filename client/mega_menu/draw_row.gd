extends SliderRow

signal control_event

const SLIDER_TEXT_BUTTON: PackedScene = preload("res://mega_menu/slider_text_button.tscn")
var brush_sizes = [10, 20, 30, 50, 80, 120]


func _ready():
	super._ready()
	
	# Add size picker buttons
	for size in brush_sizes:
		var button = SLIDER_TEXT_BUTTON.instantiate()
		add_slider(button)
		button.set_label(str(size))
		button.connect("pressed", _on_size_pressed.bind(size))
	
	# Add color picker button
	var color = Color(0, 0, 0)
	var color_button = ColorPickerButton.new()
	color_button.custom_minimum_size = Vector2(32, 32)
	color_button.color = color
	color_button.edit_alpha = false
	add_slider(color_button)
	color_button.color_changed.connect(_on_color_changed)


func _on_size_pressed(size: int):
	emit_signal("control_event", {
		"type": EditorEvents.SET_BRUSH_SIZE,
		"size": size
	})


func _on_color_changed(color: Color):
	emit_signal("control_event", {
		"type": EditorEvents.SET_BRUSH_COLOR,
		"color": color.to_html(true) # Include alpha in hex format (e.g. FFFFFFFF)
	})
