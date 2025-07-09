class_name CameraController
## Controls the camera behavior, including zoom and position smoothing.
## Adjusts zoom levels when lightbreak ability is active.


var camera: Camera2D
var target_zoom: float = 0.1
var pos: Vector2 = Vector2(0, 0)


func _init(player_camera: Camera2D):
	camera = player_camera


func process(delta: float, player_position: Vector2, lightbreak_active: bool):
	# Handle zoom based on lightbreak state
	if lightbreak_active:
		if target_zoom > GameConfig.get_value("camera_min_zoom"):
			target_zoom -= GameConfig.get_value("camera_zoom_speed") * delta
		if target_zoom < GameConfig.get_value("camera_min_zoom"):
			target_zoom = GameConfig.get_value("camera_min_zoom")
	else:
		if target_zoom < GameConfig.get_value("camera_max_zoom"):
			target_zoom += GameConfig.get_value("camera_zoom_speed") * delta
		if target_zoom > GameConfig.get_value("camera_max_zoom"):
			target_zoom = GameConfig.get_value("camera_max_zoom")
			
	# Apply zoom smoothing
	camera.zoom.x += (target_zoom - camera.zoom.x) * GameConfig.get_value("camera_zoom_smoothing")
	camera.zoom.y += (target_zoom - camera.zoom.y) * GameConfig.get_value("camera_zoom_smoothing")
	
	# Camera position smoothing
	var actual_weight = 1 - pow(1 - GameConfig.get_value("camera_position_smoothing"), delta * 30)
	pos = lerp(pos, player_position, actual_weight)
	camera.offset.x = pos.x - player_position.x
	camera.offset.y = pos.y - player_position.y
