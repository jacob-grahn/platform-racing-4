extends IconButton

signal control_event

var enabled := false


func _ready() -> void:
	super._ready()
	texture_button.pressed.connect(_on_pressed)
	var collab_texture = preload("res://mega_menu/collab_button/partner_exchange_64dp_FFFFFF_FILL0_wght400_GRAD0_opsz48.png")
	init(collab_texture, active_colors, inactive_colors)
	_emit()


func _on_pressed() -> void:
	enabled = !enabled
	# Toggle internal state, but don't call set_active
	# Instead, handle visual feedback directly
	if enabled:
		color_rect.color = active_colors.bg
		texture_rect.modulate = active_colors.icon
	else:
		color_rect.color = inactive_colors.bg
		texture_rect.modulate = inactive_colors.icon
	_emit()


func _emit() -> void:
	emit_signal("control_event", {
		"type": EditorEvents.ENABLE_COLLAB,
		"value": enabled
	})


# Override set_active to prevent this button from being included in tool selection
func set_active(p_active: bool) -> void:
	# Do nothing - this button manages its own active state
	pass
