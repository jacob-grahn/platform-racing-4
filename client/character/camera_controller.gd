class_name CameraController
## Controls the camera behavior, including zoom and position smoothing.
## Adjusts zoom levels when lightbreak ability is active.

const ZOOM_SPEED = 0.6
const MAX_ZOOM = 0.5
const MIN_ZOOM = 0.4
const ZOOM_SMOOTHING = 0.1 # smaller is smoother, slower
const POS_SMOOTHING = 0.333 # lower values take longer for camera to adjust to player position

var camera: Camera2D
var target_zoom: float = 0.1
var pos: Vector2 = Vector2(0, 0)


func _init(player_camera: Camera2D):
	camera = player_camera


func process(delta: float, player_position: Vector2, lightbreak_active: bool):
	# Handle zoom based on lightbreak state
	if lightbreak_active:
		if target_zoom > MIN_ZOOM:
			target_zoom -= ZOOM_SPEED * delta
		if target_zoom < MIN_ZOOM:
			target_zoom = MIN_ZOOM
	else:
		if target_zoom < MAX_ZOOM:
			target_zoom += ZOOM_SPEED * delta
		if target_zoom > MAX_ZOOM:
			target_zoom = MAX_ZOOM
			
	# Apply zoom smoothing
	camera.zoom.x += (target_zoom - camera.zoom.x) * ZOOM_SMOOTHING
	camera.zoom.y += (target_zoom - camera.zoom.y) * ZOOM_SMOOTHING
	
	# Camera position smoothing
	var actual_weight = 1 - pow(1 - POS_SMOOTHING, delta * 30)
	pos = lerp(pos, player_position, actual_weight)
	camera.offset.x = pos.x - player_position.x
	camera.offset.y = pos.y - player_position.y