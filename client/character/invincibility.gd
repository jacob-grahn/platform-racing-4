extends Node2D
## Manages character invincibility visual and timer.
## Provides invincibility effect for a limited time.

var timer: float = 0.0


func activate():
	var bonus = get_parent().stats.get_skill_bonus()
	timer = GameConfig.get_value("invincibility_duration") * bonus
	visible = true


func _process(delta):
	if timer > 0:
		visible = true
		timer -= delta
	else:
		visible = false


func is_active() -> bool:
	return timer > 0
