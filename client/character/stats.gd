class_name Stats
## Manages character stats and provides bonus calculations.
## Stats include jump, speed, acceleration, and skill attributes.

var jump: int = 50
var speed: int = 50
var accel: int = 50
var skill: int = 50
var force: int = 0


func get_jump_bonus() -> float:
	return 1 + (jump / 50.0)


func get_speed_bonus() -> float:
	return 1 + (speed / 50.0)


func get_accel_bonus() -> float:
	return 1 + (accel / 50.0)


func get_skill_bonus() -> float:
	return 1 + (skill / 50.0)


func set_force(num: float) -> void:
	force = num


func apply_force() -> float:
	return force


func inc_all(num: int) -> void:
	jump += num
	speed += num
	accel += num
	skill += num
	enforce_limits()


func enforce_limits() -> void:
	jump = clamp(jump, 0, 100)
	speed = clamp(speed, 0, 100)
	accel = clamp(accel, 0, 100)
	skill = clamp(skill, 0, 100)


func get_total() -> int:
	return jump + speed + accel + skill
