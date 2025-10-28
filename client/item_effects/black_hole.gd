extends CharacterBody2D

@onready var BlackHole = $BlackHole
@onready var AttractZone = $AttractZone
@onready var animations: AnimationPlayer = $Animations

var dir: float
var spawnpos: Vector2
var spawnrot: float
var life: float = 0.0
var targetalpha: float = 0.0
var z_indexspawn: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawnpos
	global_rotation = spawnrot
	life = GameConfig.get_value("black_hole_lifetime")
	BlackHole.modulate.a = 0
	targetalpha = 0.0
	animations.play("swirl")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	BlackHole.modulate.a = randf_range(0.75 * targetalpha, 1 * targetalpha)
	BlackHole.rotation += 0.043
	if targetalpha < 1 and life > 3.4:
		targetalpha += 0.005
	if life < 3.4:
		targetalpha = life / 3.4
	scale.x = BlackHole.modulate.a
	scale.y = BlackHole.modulate.a
	life -= delta
	if life <= 0:
		queue_free()
