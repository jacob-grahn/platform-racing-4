extends Node2D
class_name LaserGunItem

@onready var projectile = load("res://item_effects/laser_bullet.tscn")
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
@onready var spawn = get_node("../../../../../Projectiles")
var character: Character
var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)
var uses: int = 3


func _physics_process(delta):
	_update_animation()


func _ready():
	timer.connect("timeout", _on_timeout)
	animtimer.connect("timeout", _end_animation)
	
	
func _update_animation():
	if animtimer.time_left > 0:
		animations.play("shoot")
	else:
		animations.play("idle")


func _end_animation():
	animations.play("idle")

func activate_item():
	if !using:
		using = true
		animations.stop()
		timer.start()
		animtimer.start()
		shoot()
		if character.display.scale.x < 0:
			character.velocity.x += 750
		else:
			character.velocity.x -= 750
	uses -= 1
	if uses > 0:
		remove = false
	else:
		remove = true

func use(delta: float):
	if !using and timer.time_left < 1:
		activate_item()

func shoot():
	var bullet = projectile.instantiate()
	bullet.dir = 0
	bullet.spawnpos = global_position
	bullet.spawnrot = 0
	bullet.scale.x = character.display.scale.x
	bullet.fromplayer = character
	spawn.add_child.call_deferred(bullet)

func _on_timeout():
	using = false

func still_have_item():
	if !remove:
		return true
	else:
		return false
