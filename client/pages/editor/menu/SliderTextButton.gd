extends Node2D

signal pressed

@onready var button = $Button


func _ready():
	button.connect("pressed", _on_pressed)


func _on_pressed() -> void:
	emit_signal("pressed")


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
