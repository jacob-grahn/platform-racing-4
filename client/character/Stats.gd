class_name Stats

var jump: int = 5
var speed: int = 5
var skill: int = 5


func get_jump_bonus() -> float:
	return 1 + (jump / 20.0)


func get_speed_bonus() -> float:
	return 1 + (speed / 20.0)


func get_skill_bonus() -> float:
	return 1 + (skill / 20.0)


func inc_all(num: int) -> void:
	jump += num
	speed += num
	skill += num
	enforce_limits()


func enforce_limits() -> void:
	jump = clamp(jump, 0, 10)
	speed = clamp(speed, 0, 10)
	skill = clamp(skill, 0, 10)


func get_total() -> int:
	return jump + speed + skill
