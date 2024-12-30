extends CharacterBody2D

@onready var IceWave = $IceWave
@onready var IceWaveArea = $IceWaveArea
@export var SPEED = 800

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
	life = 2.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(SPEED, 0).rotated(dir)
	move_and_slide()
	IceWave.modulate = Color(1.0, 1.0, 1.0, randf_range((0.5 / 2.5) * life, (1.0 / 2.5) * life))
	
	if life > 0:
		life -= delta
	else:
		queue_free()
