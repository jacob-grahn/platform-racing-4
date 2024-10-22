class_name SuperJump

const SUPER_JUMP_VELOCITY = Vector2(0, -3500.0)
const CHARGE_TIMER_MAX = 1.5 # in seconds
const CHARGE_TIMER_MINIMUM_THRESHOLD = 0.5 # in seconds

var charge_timer: float = 0.0


func run(character: Character, delta: float) -> void:
	# no super jumps if we're not on the ground
	if !character.is_on_floor():
		charge_timer = 0
		return
	
	# not charging
	if !Input.is_action_pressed("down"):
		if charge_timer >= CHARGE_TIMER_MINIMUM_THRESHOLD: 
			character.velocity += SUPER_JUMP_VELOCITY.rotated(character.rotation) * ((charge_timer - CHARGE_TIMER_MINIMUM_THRESHOLD) / (CHARGE_TIMER_MAX - CHARGE_TIMER_MINIMUM_THRESHOLD))
		charge_timer = 0
		return
		
	# charging
	charge_timer += delta
	charge_timer = min(charge_timer, CHARGE_TIMER_MAX)


func is_charging():
	return charge_timer > 0


func is_locking():
	return charge_timer > CHARGE_TIMER_MINIMUM_THRESHOLD


func is_fully_charged():
	return charge_timer == CHARGE_TIMER_MAX
