extends Node2D

var min_frames: int = 5
@onready var line_1 = $Line1
@onready var line_2 = $Line2


func _on_ready():
	pass


func _process(_delta):
	if min_frames > 0:
		min_frames -= 1
	
	if min_frames > 0:
		return
	
	if line_1.get_point_count() > 0:
		line_1.remove_point(0)
		line_2.remove_point(0)
		return
		
	queue_free()


func add_point(point: Vector2) -> void:
	min_frames = 5
	line_1.add_point(point)
	line_2.add_point(point)
