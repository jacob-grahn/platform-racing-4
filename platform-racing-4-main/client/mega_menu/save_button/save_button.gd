extends IconButton

signal save_pressed


func _ready() -> void:
	super._ready()
	texture_button.pressed.connect(_on_pressed)
	var save_texture = preload("res://mega_menu/icons/save.png")
	init(save_texture, active_colors, inactive_colors)


func _on_pressed() -> void:
	emit_signal("save_pressed")


# Override set_active to prevent this button from being activated
func set_active(p_active: bool) -> void:
	# Do nothing - this button should never show as active
	pass