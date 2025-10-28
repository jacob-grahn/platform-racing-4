extends CharacterBody2D

@onready var LaserBullet = $LaserBullet
@onready var LaserBulletCollision = $LaserBulletCollision

var dir: float
var spawnpos: Vector2
var spawnrot: float
var life: float = 0.0
var speed = GameConfig.get_value("laser_bullet_speed")
var fromplayer: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	life = GameConfig.get_value("laser_bullet_lifetime")

func check_collision() -> bool:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if !collision:
		return false
	else:
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	var hit_something = check_collision()
	if life <= 0:
		queue_free()
	elif !hit_something:
		life -= delta
	else:
		if hit_something:
			print("we hit something bois!")
		queue_free()
