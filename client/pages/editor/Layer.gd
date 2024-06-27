extends Node2D


func _process(delta):
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		position = camera.get_screen_center_position() * (1 - scale.x)
