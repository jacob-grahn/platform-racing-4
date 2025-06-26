extends CharacterBody2D

var walk_velocity = 200
var run_velocity = 1200
var current_velocity = 0
var walk_direction: bool = true
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
@onready var display = $Display
@onready var timer = $Timer
@onready var SightArea = $SightArea
@onready var animations: AnimationPlayer = $Animations


func _ready():
	current_velocity = walk_velocity
	display.get_node("Egg2/EggColor").self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	display.get_node("Egg2/EggSpots").self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	display.get_node("FootFront/Color").self_modulate = Color(randf_range(0.0, 1.0), randf_range(0.0, 1.0), randf_range(0.0, 1.0))
	display.get_node("FootBack/Color").self_modulate = display.get_node("FootFront/Color").self_modulate
	animations.play("walk")


func check_collision():
	if abs(velocity.x) < current_velocity / 4:
		walk_direction = !walk_direction
	if walk_direction:
		velocity.x = -current_velocity
		display.scale.x = -1
	else:
		velocity.x = current_velocity
		display.scale.x = 1


func _physics_process(delta):
	velocity += gravity * delta
	move_and_slide()
	check_collision()

func detect_players():
	var collision: Array = SightArea.get_overlapping_areas()


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
