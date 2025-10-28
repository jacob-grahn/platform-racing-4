extends Item
class_name LaserGunItem

@onready var projectile = load("res://item_effects/laser_bullet.tscn")
@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item():
	uses = GameConfig.get_value("uses_laser_gun")


func _play_idle_animation():
	animations.play("idle")


func activate_item():
	if !using:
		using = true
		animations.stop()
		animations.play("shoot")
		animation_timer.start(animations.get_current_animation_length())
		reload_timer.start(0.8)
		shoot()
		if character.display.scale.x < 0:
			character.velocity.x += 750
		else:
			character.velocity.x -= 750
		uses -= 1


func use(delta: float):
	if character and !using:
		activate_item()


func shoot():
	var bullet = projectile.instantiate()
	bullet.dir = 0
	bullet.spawnpos = global_position
	bullet.spawnrot = 0
	bullet.scale.x = character.display.scale.x
	bullet.speed = GameConfig.get_value("laser_bullet_speed") * character.movement.facing
	bullet.fromplayer = character
	spawn.add_child.call_deferred(bullet)
	Jukebox.play_sound("laser")


func _remove_item():
	animation_timer.stop()
	_play_idle_animation()
