extends CharacterBody2D

@onready var LaserBullet = $LaserBullet
@onready var LaserBulletArea = $LaserBulletArea
@export var SPEED = 4800

var dir: float
var spawnpos: Vector2
var spawnrot: float
var life: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	if scale.x < 0:
		SPEED = -SPEED
	else:
		SPEED = SPEED
	life = 3.3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(SPEED, 0).rotated(dir)
	move_and_slide()
	
	if life > 0:
		life -= delta
	else:
		queue_free()
