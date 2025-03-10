extends IconButton

var zoom_controller: ZoomController


func _ready() -> void:
	super._ready()
	var zoom_out_texture = preload("res://mega_menu/icons/zoom_out.png")
	
	# Light blue colors
	var active_colors = {
		"bg": Color("2a9fd6"),
		"icon": Color("ffffff")
	}
	var inactive_colors = {
		"bg": Color("ffffff"),
		"icon": Color("2a9fd6")
	}
	
	init(zoom_out_texture, active_colors, inactive_colors)
	texture_button.pressed.connect(_on_pressed)


func setup(controller: ZoomController) -> void:
	zoom_controller = controller


func _on_pressed() -> void:
	if zoom_controller:
		zoom_controller.zoom_out()


# Override set_active to prevent this button from being activated
func set_active(p_active: bool) -> void:
	# Do nothing - this button should never show as active
	pass