extends Node2D

var brush_size: float
var size_multiplier: float


func _ready() -> void:
	pass


func _draw() -> void:
	draw_arc(Vector2.ZERO, brush_size / size_multiplier, 0.0, 360.0, 50, Color("FFFFFFFF"), 0.5, true)


func set_brush_circle(new_brush_size: float, new_size_multiplier: float) -> void:
	brush_size = new_brush_size
	size_multiplier = new_size_multiplier
	queue_redraw()
