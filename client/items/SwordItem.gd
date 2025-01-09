extends Node2D
class_name SwordItem

@onready var main = get_tree().get_root()
@onready var swordslash = load("res://item_effects/SwordSlash.tscn")
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
@onready var character = get_node("../../..")
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
		animations.play("swing")
	else:
		animations.play("idle")

func _end_animation():
	animations.play("idle")

# no hitboxes/collison for sword slash yet.

func activate_item():
	if !using:
		using = true
		animations.stop()
		timer.start()
		animtimer.start()
		slash()
		if character.display.scale.x < 0:
			character.velocity.x -= 1000
		else:
			character.velocity.x += 1000
		uses -= 1
	if uses > 0:
		remove = false
	else:
		remove = true

func use(delta: float):
	if !using and timer.time_left < 1:
		activate_item()

func slash():
	var slash = swordslash.instantiate()
	slash.dir = 0
	slash.spawnpos = global_position
	slash.spawnrot = 0
	slash.scale.x = character.display.scale.x
	main.add_child.call_deferred(slash)

func _on_timeout():
	using = false

func still_have_item():
	if !remove:
		return true
	else:
		return false
