extends CharacterBody2D

@onready var SwordSlash = $SwordSlash
@export var SPEED = 0

var dir: float
var spawnpos: Vector2
var spawnrot: float
var velx: float

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	velx = scale.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2((1050 / (SwordSlash.get_frame() + 1)) * velx, 0).rotated(dir)
	move_and_slide()
	if SwordSlash.is_playing():
		pass
	else:
		queue_free()
