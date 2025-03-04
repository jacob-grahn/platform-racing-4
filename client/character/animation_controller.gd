class_name AnimationController
## Controls character animations based on state.
## Handles animation selection, direction, and special effects like super jump.

var display: Node2D
var sjaura: Node2D
var shake: float = 0.0
var sjanim: float = 0.0


func _init(character_display: Node2D, super_jump_aura: Node2D):
	display = character_display
	sjaura = super_jump_aura


func process(character: Character, movement: MovementController, super_jump: SuperJump):
	# Face left or right
	var control_vector = Input.get_vector("left", "right", "up", "down")
	if !movement.hurt:
		display.scale.x = movement.facing
	else:
		if (movement.hitstun_duration - movement.hitstun_timer) < 0.4:
			display.play(CharacterDisplay.HURT_START)
		elif movement.hitstun_timer > 0.5:
			display.play(CharacterDisplay.HURT)
		else:
			display.play(CharacterDisplay.RECOVER)
	
	# Animation speed adjustment for frozen or charging states
	if movement.frozen:
		display.set_speed_scale(1 - movement.frozen_display_node.modulate.a)
	elif super_jump.is_locking() and super_jump.charge_precentage() < 1:
		display.set_speed_scale(1 / super_jump.CHARGE_TIMER_MAX)
	else:
		display.set_speed_scale(1)
	
	# Crouching
	if !movement.hurt and movement.is_crouching:
		if control_vector.x != 0:
			display.play(CharacterDisplay.CRAWL)
		else:
			display.play(CharacterDisplay.CROUCH)
	
	# On ground
	elif !movement.hurt and character.is_on_floor():
		if super_jump.is_locking():
			if super_jump.charge_precentage() < 1:
				display.play(CharacterDisplay.CHARGE)
			else:
				display.play(CharacterDisplay.CHARGE_HOLD)
		elif control_vector.x != 0:
			display.play(CharacterDisplay.RUN)
		else:
			display.play(CharacterDisplay.IDLE)
	
	# In the air
	elif !movement.hurt and movement.swimming:
		display.play(CharacterDisplay.SWIM)
	elif !movement.hurt:
		display.play(CharacterDisplay.JUMP)
	
	# Super jump charge effect
	shake = super_jump.charge_precentage() / 8
	sjanim = randf_range(1 - shake, 1 + shake)
	if super_jump.is_locking():
		display.scale.y = sjanim
		if !movement.frozen:
			display.modulate.b = 1.0 - super_jump.charge_precentage()
		sjaura.modulate.a = super_jump.charge_precentage() / 2
		sjaura.scale.y = super_jump.charge_precentage() / 2
		if !sjaura.visible:
			sjaura.visible = true
	else:
		if sjaura.visible:
			sjaura.visible = false
		if !movement.frozen:
			display.modulate = Color(1.0, 1.0, 1.0)
		display.scale.y = 1
		display.scale.x = movement.facing
		shake = 0