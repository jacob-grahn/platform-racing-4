extends SliderItem

signal pressed

@onready var button = $Content/Button


func _ready():
	super._ready()
	button.connect("pressed", _on_pressed)


func _on_pressed() -> void:
	emit_signal("pressed", get_label())


func get_dimensions() -> Vector2:
	return button.size


func set_label(str: String) -> void:
	button.text = str


func get_label() -> String:
	return button.text


func set_focus(focus: bool) -> void:
	if focus:
		button.grab_focus()
	else:
		button.release_focus()
