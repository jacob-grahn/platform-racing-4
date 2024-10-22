extends Camera2D

var velocity = 2000
var camera_zoom = 1.0
var camera_speed_multiplier = 1.0


func _ready():
	pass # Replace with function body.
	set_position_smoothing_enabled(true)
	set_position_smoothing_speed(7)


func _process(delta):
	set_zoom(Vector2(0.5 * camera_zoom, 0.5 * camera_zoom))
	var control_vector = Input.get_vector("left", "right", "up", "down")
	if Input.is_key_pressed(KEY_CTRL):
		camera_speed_multiplier = 2.5
	else:
		camera_speed_multiplier = 1.0
	position += control_vector * (velocity * camera_speed_multiplier) * delta
