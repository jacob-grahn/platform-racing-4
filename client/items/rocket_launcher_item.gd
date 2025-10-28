extends Item
class_name RocketLauncherItem

@onready var projectile = load("res://item_effects/rocket.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item() -> void:
	uses = GameConfig.get_value("uses_rocket_launcher")


func _play_idle_animation():
	animations.play("idle")


# rocket collision not yet finished.
func activate_item():
	if !using:
		using = true
		animations.stop()
		animations.play("launch")
		animation_timer.start(animations.get_current_animation_length())
		reload_timer.start(1)
		launch()
		if character.movement.facing > 0:
			character.velocity.x += 2500
		else:
			character.velocity.x -= 2500
		get_parent().uses -= 1


func launch():
	var rocket = projectile.instantiate()
	rocket.dir = 0
	rocket.spawnpos = global_position
	rocket.spawnrot = 0
	rocket.scale.x = character.movement.facing
	if !spawn:
		var layer = Game.get_target_block_layer_node()
		spawn = layer.get_node("Projectiles")
	spawn.add_child.call_deferred(rocket)


func _remove_item():
	animation_timer.stop()
	_play_idle_animation()
