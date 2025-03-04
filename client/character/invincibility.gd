extends Node2D

var timer_reset = 5.0
var timer = 0.0


func activate():
	var bonus = get_parent().stats.get_skill_bonus()
	timer = timer_reset * bonus
	visible = true


func _process(delta):
	if timer > 0:
		visible = true
		timer -= delta
	else:
		visible = false


func is_active() -> bool:
	return timer > 0
