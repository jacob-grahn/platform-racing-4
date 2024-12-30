extends Node2D
class_name AngelWingsItem

@onready var player = get_parent().get_parent()
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)

func _physics_process(delta):
	if using:
		if player.velocity.y >= 0:
			player.velocity.y = 0
		if player.velocity.y >= -3000:
			boost = Vector2(100, -60)
		else:
			boost = Vector2(100, 0)
	else:
		boost = Vector2(0, 0)
	_update_animation()

func _ready():
	timer.connect("timeout", _on_timeout)
	animtimer.connect("timeout", _end_animation)
	
func _update_animation():
	if animtimer.time_left > 0:
		animations.play("flap")
	else:
		animations.play("idle")

func _end_animation():
	if (get_parent().uses - 1) < 1:
		remove = true
	
func activate_item():
	if !using:
		using = true
		animations.stop()
		timer.start()
		animtimer.start()

func get_force(delta: float):
	if using:
		return boost
	else:
		return Vector2(0, 0)

func _on_timeout():
	get_parent().uses -= 1
	using = false

func still_have_item():
	if !remove:
		return true
	else:
		return false
