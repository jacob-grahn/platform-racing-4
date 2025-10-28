extends CharacterBody2D

@onready var Rocket = $Rocket
@export var SPEED = 0

var dir: float
var spawnpos: Vector2
var spawnrot: float
var life: float = 0.0
var velx: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	velx = scale.x
	life = GameConfig.get_value("rocket_lifetime")
	Jukebox.play_sound("misslelauncher")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2(SPEED, 0).rotated(dir)
	move_and_slide()
	if velx > 0 and SPEED < 2400:
		SPEED += 50
	elif SPEED > -2400:
		SPEED -= 50
	if life > 0:
		life -= delta
	else:
		queue_free()
