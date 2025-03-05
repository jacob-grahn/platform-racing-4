class_name MovementController
## Controls character movement, including walking, jumping, and swimming.
## Handles physics, frozen status, and damage hitstun.

const SPEED = 490.0
const JUMP_VELOCITY = Vector2(0, -155.0)
const FASTFALL_VELOCITY = Vector2(0, 50.0)
const MAX_VELOCITY = Vector2(4500.0, 3750.0)
const SWIM_UP_VELOCITY = Vector2(0, -SPEED * 7)
const TRACTION = 4000
const FRICTION = 0.1
const FRICTION_SWIMMING = 2
const JUMP_VELOCITY_MULTIPLIER = 0.75
const JUMP_TIMER_MAX = 10.0

var jump_timer: float = 0
var facing: int = 1
var jumped: bool = false
var can_move: bool = true
var can_jump: bool = true
var is_crouching: bool = false
var previous_velocity: Vector2 = Vector2(0, 0)
var last_velocity: Vector2 = Vector2(0, 0)
var last_collision_normal: Vector2 = Vector2(0, 0)
var swimming: bool = false
var phantom_velocity: Vector2 = Vector2(0, 0)
var phantom_velocity_decay: float = 0.25
var frozen: bool = false
var frozen_timer: float = 0.0
var frozen_display_node = null
var hurt: bool = false
var hitstun_timer: float = 0.0
var hitstun_duration: float = 0.0


func _init(ice_node = null):
	frozen_display_node = ice_node


func process(delta: float, character: Character, stats: Stats, gravity: Gravity, super_jump: SuperJump) -> Vector2:
	var velocity = character.velocity
	
	# Process freezing effect
	var traction = TRACTION
	if frozen and frozen_timer >= 0:
		frozen_timer -= delta
		if frozen_display_node:
			frozen_display_node.visible = true
			frozen_display_node.modulate.a = ((1 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
			frozen_display_node.scale.y = ((0.65 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
			character.display.modulate = Color(1.0 - (frozen_display_node.modulate.a / 2), 1.0, 1.0)
		traction = TRACTION / 10.0
	else:
		if frozen_display_node:
			frozen_display_node.visible = false
		frozen = false
	
	# Process hitstun
	if hurt:
		if hitstun_timer > 0:
			hitstun_timer -= delta
		else:
			hurt = false
	
	# Handle input for movement
	var control_axis: float = Input.get_axis("left", "right")
	if !hurt and control_axis < 0:
		facing = -1
	elif !hurt and control_axis > 0:
		facing = 1
		
	# Checks if player is rotating
	var not_rotating: bool = gravity.not_rotating(delta)
	
	# Handle jump
	if not hurt and can_jump and Input.is_action_pressed("jump"):
		if is_crouching:
			_bump_tile_covering_high_area(character)
		elif character.is_on_floor() and velocity.rotated(-character.rotation).y > JUMP_VELOCITY.y * JUMP_VELOCITY_MULTIPLIER:
			jumped = true
			jump_timer = JUMP_TIMER_MAX
	
	# Handle jump strength/velocity increment
	if not_rotating and jumped:
		velocity += JUMP_VELOCITY.rotated(character.rotation) * stats.get_jump_bonus() * (jump_timer / JUMP_TIMER_MAX)
		jump_timer -= 1
		if jump_timer <= 0:
			jumped = false
			jump_timer = 0
			
	# Caps velocity to reasonable limits
	velocity = _cap_velocity(velocity)
			
	# Airborne behavior
	if not_rotating and not character.is_on_floor():
		# Cancel jump early by not pressing jump
		if jumped and not Input.is_action_pressed("jump"):
			jumped = false
		# Fastfall; if down pressed while not on floor, fall faster
		if !hurt and Input.is_action_pressed("down"):
			if swimming:
				velocity += (FASTFALL_VELOCITY / 2).rotated(character.rotation)
			else:
				velocity += FASTFALL_VELOCITY.rotated(character.rotation)
		# Swimming up
		if !hurt and swimming and Input.is_action_pressed("up"):
			velocity += SWIM_UP_VELOCITY.rotated(character.rotation) * delta
		# Extra jump is gone after releasing jump button
		if not jumped:
			jump_timer = 0
	
	# Horizontal movement
	if not_rotating:
		if hurt or super_jump.is_locking():
			control_axis = 0
		if !hurt and is_crouching:
			control_axis = control_axis / 2
			
		var target_velocity = Vector2(control_axis * SPEED * stats.get_speed_bonus(), 
				velocity.rotated(-character.rotation).y).rotated(character.rotation)
		var accel = 0.8 * (stats.get_accel_bonus() / 1.5)
		
		if control_axis != 0:
			if target_velocity.length() > velocity.length():
				traction *= accel
			velocity = velocity.move_toward(target_velocity, delta * traction)
		else:
			velocity = velocity.move_toward(target_velocity, delta * traction * accel)
	
	# Add friction
	var friction = FRICTION
	if swimming:
		friction = FRICTION_SWIMMING
	velocity = velocity * (1 - (friction * delta))
	
	# Add phantom velocity
	velocity += phantom_velocity
	phantom_velocity = phantom_velocity * phantom_velocity_decay
	
	# Save for next frame
	previous_velocity = velocity
	last_velocity = velocity
	
	return velocity


func _cap_velocity(velocity: Vector2) -> Vector2:
	if abs(velocity.x) > MAX_VELOCITY.x:
		if velocity.x > 0:
			velocity.x = MAX_VELOCITY.x
		else:
			velocity.x = MAX_VELOCITY.x * -1
	if abs(velocity.y) > MAX_VELOCITY.y:
		if velocity.y > 0:
			velocity.y = MAX_VELOCITY.y
		else:
			velocity.y = MAX_VELOCITY.y * -1
	return velocity


func _bump_tile_covering_high_area(character: Character):
	# This needs to be implemented in the character class
	# as it depends on game and tile interactions
	character._bump_tile_covering_high_area()


func freeze(skill_bonus: float):
	frozen = true
	frozen_timer = 3.0 / skill_bonus


func hitstun(duration: float, has_shield: bool):
	if !has_shield and !hurt:
		hitstun_duration = duration
		hitstun_timer = duration
		frozen_timer = 0
		frozen = false
		hurt = true
