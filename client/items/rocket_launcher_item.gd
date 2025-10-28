extends Node2D
class_name RocketLauncherItem

@onready var projectile = load("res://item_effects/rocket.tscn")
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
var character: Character
var spawn: Node2D
var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)
var uses: int = 1


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
		if character.display.scale.x < 0:
			character.velocity.x += 2500
		else:
			character.velocity.x -= 2500
	uses -= 1
	if uses > 0:
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
	rocket.scale.x = character.display.scale.x
	if !spawn:
		var layer = Game.get_target_layer_node()
		spawn = layer.get_node("Projectiles")
	spawn.add_child.call_deferred(rocket)

func _on_timeout():
	using = false

func still_have_item():
	if !remove:
		return true
	else:
		return false
