extends Camera2D

var velocity = 2000
var camera_zoom = 1.0
var target_zoom = 1.0
var is_zooming : bool = false
var camera_speed_multiplier = 1.0


func _ready():
	set_position_smoothing_enabled(true)
	set_position_smoothing_speed(7)


func _process(delta):
	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner and (focus_owner is LineEdit or focus_owner is TextEdit):
		return
		
	set_zoom(Vector2(camera_zoom, camera_zoom))
	var control_vector = Input.get_vector("left", "right", "up", "down")
	if Input.is_key_pressed(KEY_CTRL):
		camera_speed_multiplier = 2.5
	else:
		camera_speed_multiplier = 1.0
	position += control_vector * (velocity * camera_speed_multiplier) * delta
	
	if is_zooming:
		var factor_to_zoom = target_zoom / camera_zoom
		camera_zoom = lerp(camera_zoom, target_zoom, factor_to_zoom*delta*5)
		if abs(factor_to_zoom - 1) < 0.001:
			camera_zoom = target_zoom
			is_zooming = false


func change_camera_zoom(new_zoom_value):
	is_zooming = true
	target_zoom = new_zoom_value
