extends IconButton

signal control_event

var enabled := false


func _ready() -> void:
	super._ready()
	texture_button.pressed.connect(_on_pressed)
	var config_texture = preload("res://icon.svg") # Replace with a proper icon
	init(config_texture, active_colors, inactive_colors)
	_emit()


func _on_pressed() -> void:
	enabled = !enabled
	if enabled:
		color_rect.color = active_colors.bg
		texture_rect.modulate = active_colors.icon
	else:
		color_rect.color = inactive_colors.bg
		texture_rect.modulate = inactive_colors.icon
	_emit()


func _emit() -> void:
	emit_signal("control_event", {
		"type": "toggle_game_config",
		"value": enabled
	})


func set_active(p_active: bool) -> void:
	pass
