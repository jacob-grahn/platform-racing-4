extends CharacterBody2D

@onready var SwordArea = $SwordArea
@onready var animations: AnimationPlayer = $Animations
@export var SPEED = 0

var dir: float
var spawnpos: Vector2
var spawnrot: float
var velx: float
var life: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	velx = scale.x
	life = GameConfig.get_value("sword_slash_lifetime")
	animations.play("slash")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity = Vector2((2500 * (life * 5)) * velx, 0).rotated(dir)
	move_and_slide()
	if life > 0:
		life -= delta
	else:
		queue_free()
