extends CharacterBody2D

@onready var LaserBullet = $LaserBullet
@onready var LaserBulletCollision = $LaserBulletCollision
@export var SPEED = 4800

var dir: float
var spawnpos: Vector2
var spawnrot: float
var life: float = 0.0
var fromplayer: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	if scale.x < 0:
		SPEED = -SPEED
	else:
		SPEED = SPEED
	life = 3.3

func check_collision() -> bool:
	var collision: KinematicCollision2D = get_last_slide_collision()
	if !collision:
		return false
	else:
		return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(SPEED, 0).rotated(dir)
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
