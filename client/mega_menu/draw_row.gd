extends SliderRow

signal control_event

const ICON_BUTTON: PackedScene = preload("res://ui/icon_button.tscn")
var brush_sizes = [10, 20, 30, 50, 80, 120]


func _ready():
	super._ready()
	
	# Light blue colors
	var active_colors = {
		"bg": Color("2a9fd6"),
		"icon": Color("ffffff")
	}
	var inactive_colors = {
		"bg": Color("ffffff"), 
		"icon": Color("2a9fd6")
	}
	
	# Add size picker buttons
	for size in brush_sizes:
		var button = ICON_BUTTON.instantiate()
		add_slider(button)
		button.init(null, active_colors, inactive_colors)
		
		# Add text overlay
		var label = Label.new()
		label.text = str(size)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(64, 64)
		label.add_theme_color_override("font_color", Color("000000"))
		button.add_child(label)
		
		button.texture_button.pressed.connect(_on_size_pressed.bind(size))
	
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
