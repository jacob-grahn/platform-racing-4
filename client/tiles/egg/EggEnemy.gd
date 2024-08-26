extends CharacterBody2D

var walk_velocity = 200
var walk_direction: bool = true
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
@onready var display = $Display
@onready var timer = $Timer


func _ready():
	timer.connect("timeout", _on_timeout)


func _on_timeout():
	if abs(velocity.x) < walk_velocity / 4:
		walk_direction = !walk_direction
	if walk_direction:
		velocity.x = walk_velocity
		display.scale.x = -1
	else:
		velocity.x = -walk_velocity
		display.scale.x = 1


func _physics_process(delta):
	velocity += gravity * delta
	move_and_slide()


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
