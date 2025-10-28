extends Item
class_name IceWaveItem

@onready var projectile = load("res://item_effects/ice_wave.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item():
	uses = GameConfig.get_value("uses_ice_wave")


func _play_idle_animation():
	animations.play("idle")


func activate_item():
	if character and !using:
		using = true
		animations.stop()
		animations.play("shoot")
		animation_timer.start(animations.get_current_animation_length())
		reload_timer.start(1.777)
		shoot()
		uses -= 1

# ice waves seem to overwrite each other, causing-
# one of the ice waves to suddenly change direction.
# also they don't freeze blocks at the moment. maybe
# the current ice blocks mechanic that freezes the
# player instead of just slowing down the player's
# acceleration could be reserved for the ice wave?

func shoot():
	var icewave1 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave1)
	icewave1.dir = 112.5
	icewave1.spawnpos = global_position
	icewave1.spawnrot = 112.5
	icewave1.scale.x = character.movement.facing
	var icewave2 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave2)
	icewave2.dir = 0
	icewave2.spawnpos = global_position
	icewave2.spawnrot = 0
	icewave2.scale.x = character.movement.facing
	var icewave3 = projectile.instantiate()
	spawn.add_child.call_deferred(icewave3)
	icewave3.dir = -112.5
	icewave3.spawnpos = global_position
	icewave3.spawnrot = -112.5
	icewave3.scale.x = character.movement.facing
	Jukebox.play_sound("icewave")


func _remove_item():
	animation_timer.stop()
	_play_idle_animation()
