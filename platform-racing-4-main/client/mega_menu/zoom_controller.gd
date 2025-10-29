extends Node
class_name ZoomController

signal zoom_changed(zoom_event)

# Zoom settings
var zoom_increment: int = 3
var min_zoom_increment: int = 0
var max_zoom_increment: int = 6
var zoom_amounts: Array = [25, 50, 75, 100, 150, 250, 500] # Zoom amounts listed in percentage.


func zoom_in() -> void:
	zoom_increment += 1
	_update_zoom()


func zoom_out() -> void:
	zoom_increment -= 1
	_update_zoom()


func _update_zoom() -> void:
	zoom_increment = clamp(zoom_increment, min_zoom_increment, max_zoom_increment)
	
	emit_signal("zoom_changed", {
		"type": "editor_camera_zoom_change",
		"zoom": 0.5 * zoom_amounts[zoom_increment] / 100.0
	})


func get_current_zoom() -> float:
	return 0.5 * zoom_amounts[zoom_increment] / 100.0
