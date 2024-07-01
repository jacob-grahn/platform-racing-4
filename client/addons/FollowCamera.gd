extends Node2D

var parent: Node2D


func _ready():
	parent = get_parent()
	

func _process(delta):
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		parent.position = camera.get_screen_center_position()
		parent.scale = Vector2.ONE / camera.zoom
