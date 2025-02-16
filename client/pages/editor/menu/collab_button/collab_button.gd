extends Node2D

signal control_event

var enabled := false
@onready var texture_button: TextureButton = $TextureButton


func _ready() -> void:
	texture_button.pressed.connect(_on_pressed)
	_emit()


func _on_pressed() -> void:
	enabled = !enabled
	_emit()


func _emit() -> void:
	emit_signal("control_event", {
		"type": EditorEvents.ENABLE_COLLAB,
		"value": enabled
	})
