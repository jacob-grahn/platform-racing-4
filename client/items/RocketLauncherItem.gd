extends Node2D
class_name RocketLauncherItem

@onready var main = get_tree().get_root()
@onready var projectile = load("res://item_effects/Rocket.tscn")
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)


func _physics_process(delta):
	_update_animation()

func _ready():
	timer.connect("timeout", _on_timeout)
	animtimer.connect("timeout", _end_animation)
	
func _update_animation():
	if animtimer.time_left > 0:
		animations.play("launch")
	else:
		animations.play("idle")

func _end_animation():
	animations.play("idle")

# rocket collision not yet finished.

func activate_item():
	if !using:
		using = true
		animations.stop()
		timer.start()
		animtimer.start()
		launch()
		if scale.x < 0:
			get_parent().get_parent().velocity.x += 2500
		else:
			get_parent().get_parent().velocity.x -= 2500
	get_parent().uses -= 1
	if get_parent().uses > 0:
		remove = false
	else:
		remove = true

func use(delta: float):
	if !using and timer.time_left < 1:
		activate_item()

func launch():
	var rocket = projectile.instantiate()
	rocket.dir = 0
	rocket.spawnpos = global_position
	rocket.spawnrot = 0
	rocket.scale.x = scale.x
	main.add_child.call_deferred(rocket)

func _on_timeout():
	using = false

func still_have_item():
	if !remove:
		return true
	else:
		return false
