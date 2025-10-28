extends Item
class_name SwordItem

@onready var swordslash = load("res://item_effects/sword_slash.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item():
	uses = GameConfig.get_value("uses_sword")


func _play_idle_animation():
	animations.play("idle")


# no hitboxes/collison for sword slash yet.
func activate_item():
	if character and !using:
		using = true
		animations.stop()
		animations.play("swing")
		animation_timer.start(animations.get_current_animation_length())
		reload_timer.start(0.5)
		slash()
		if character.display.scale.x < 0:
			character.velocity.x -= 1000
		else:
			character.velocity.x += 1000
		uses -= 1


func slash():
	var slash = swordslash.instantiate()
	slash.dir = 0
	slash.spawnpos = global_position
	slash.spawnrot = 0
	slash.scale.x = character.movement.facing
	spawn.add_child.call_deferred(slash)


func _remove_item():
	animation_timer.stop()
	_play_idle_animation()
