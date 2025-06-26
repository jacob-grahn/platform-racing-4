extends Node2D
class_name SpeedBurstItem

var character: Character
var using: bool = false
var remove: bool = false
var timer: float = 0.0
var speed: float = 0.0
var boost = Vector2(0, 0)


func _ready():
	timer = 6.0


func _physics_process(delta):
	check_if_used()
	# method of applying speed burst to player is-
	# absolutely sloppy at the moment. does not-
	# account for super jumping and doesn't cap.
	var control_axis: float = Input.get_axis("left", "right")
	if using:
		if control_axis != 0:
			speed = 50 * character.stats.get_speed_bonus()
			boost = Vector2(speed, 0)
		timer -= delta
	else:
		boost = Vector2(0, 0)


func activate_item():
	if !using:
		using = true
		character.speed_particles.emitting = true


func check_if_used():
	if timer > 0:
		remove = false
	else:
		character.speed_particles.emitting = false
		remove = true


func get_force(delta: float):
	if using:
		return boost
	else:
		return Vector2(0, 0)


func still_have_item():
	if !remove:
		return true
	else:
		return false


func _exit_tree():
	character.speed_particles.emitting = false
