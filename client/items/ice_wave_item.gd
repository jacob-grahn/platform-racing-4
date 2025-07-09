extends Node2D
class_name IceWaveItem

@onready var projectile = load("res://item_effects/ice_wave.tscn")
@onready var timer = $CooldownTimer
@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations
var character: Character
var spawn: Node2D
var using: bool = false
var remove: bool = false
var uses: int = 3


func _physics_process(delta):
	check_if_used()
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


func check_if_used():
	if uses < 1:
		remove = true


func activate_item():
	if !using:
		using = true
		animations.stop()
		timer.start()
		animtimer.start()
		shoot()
		uses -= 1

# ice waves seem to overwrite each other, causing-
# one of the ice waves to suddenly change direction.
# also they don't freeze blocks at the moment. maybe
# the current ice blocks mechanic that freezes the
# player instead of just slowing down the player's
# acceleration could be reserved for the ice wave?

func shoot():
	if !spawn:
		var target_layer_name: String = Game.game.level_manager.layers.get_target_layer()
		var layer = Game.game.level_manager.layers.get_node(target_layer_name)
		spawn = layer.get_node("Projectiles")
	var icewave1 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave1)
	icewave1.dir = 112.5
	icewave1.spawnpos = global_position
	icewave1.spawnrot = 112.5
	icewave1.scale.x = character.display.scale.x
	var icewave2 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave2)
	icewave2.dir = 0
	icewave2.spawnpos = global_position
	icewave2.spawnrot = 0
	icewave2.scale.x = character.display.scale.x
	var icewave3 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave3)
	icewave3.dir = -112.5
	icewave3.spawnpos = global_position
	icewave3.spawnrot = -112.5
	icewave3.scale.x = character.display.scale.x
	
	
func _on_timeout():
	using = false


func still_have_item():
	if !remove:
		return true
	else:
		return false
