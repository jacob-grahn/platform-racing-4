class_name Stats

var jump: int = 0
var speed: int = 0
var accel: int = 0
var skill: int = 0


func get_jump_bonus() -> float:
	return 1 + (jump / 20.0)

func get_speed_bonus() -> float:
	return 1 + (speed / 20.0)
	
func get_accel_bonus() -> float:
	return 1 + (accel / 20.0)

func get_skill_bonus() -> float:
	return 1 + (skill / 20.0)


func inc_all(num: int) -> void:
	jump += num
	speed += num
	accel += num
	skill += num
	enforce_limits()


func enforce_limits() -> void:
	jump = clamp(jump, -10, 10)
	speed = clamp(speed, -10, 10)
	accel = clamp(accel, -10, 10)
	skill = clamp(skill, -10, 10)


func get_total() -> int:
	return jump + speed + accel + skill
