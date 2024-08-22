class_name Gravity

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var gravity_rotated: Vector2 = Vector2(gravity)
var base_up_direction = Vector2(0, -1)
var rotation: float = 0
var target_rotation: float = 0
var rotate_speed: float = 0.05


func run(character: Character, delta: float) -> void:
	# Rotate
	if rotation != target_rotation:
		var rotation_dist = clamp(rotation - target_rotation, -rotate_speed, rotate_speed)
		if abs(rotation_dist) < rotate_speed:
			rotation = target_rotation
			target_rotation = rotation # deal with rotation switching from negative to positive
		else:
			rotation -= rotation_dist
		gravity_rotated = gravity.rotated(rotation)
	
	# Apply to character
	character.rotation = rotation
	character.up_direction = base_up_direction.rotated(rotation)
	if not character.is_on_floor():
		character.velocity += gravity_rotated * delta
