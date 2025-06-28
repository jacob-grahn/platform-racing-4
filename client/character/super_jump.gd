class_name SuperJump
## Handles the super jump ability charging and execution.
## Manages charge timers and provides state information.

const SUPER_JUMP_VELOCITY = Vector2(0, -3500.0)
const CHARGE_TIMER_MAX = 1.5 # in seconds
const CHARGE_TIMER_MINIMUM_THRESHOLD = 0.5 # in seconds
const SUPER_JUMP_SOUND := preload("res://sounds/SuperJumpSound.ogg")

var charge_timer: float = 0.0
var sjanim_timer: float = 0.0


func run(character: Character, delta: float) -> void:
	# no super jumps if we're not on the ground (or crouching)
	if !character.is_on_floor():
		charge_timer = 0
		sjanim_timer = 0
		return
	
	# not charging
	if !Input.is_action_pressed("down"):
		if !character.movement.is_crouching and charge_timer >= CHARGE_TIMER_MINIMUM_THRESHOLD: 
			character.velocity += SUPER_JUMP_VELOCITY.rotated(character.rotation) * (
					(charge_timer - CHARGE_TIMER_MINIMUM_THRESHOLD) / 
					(CHARGE_TIMER_MAX - CHARGE_TIMER_MINIMUM_THRESHOLD))
		if charge_timer >= CHARGE_TIMER_MINIMUM_THRESHOLD:
			character.audioplayer.set_stream(SUPER_JUMP_SOUND)
			character.audioplayer.set_volume_db(linear_to_db(sjanim_timer))
			character.audioplayer.play()
		charge_timer = 0
		sjanim_timer = 0
		return
		
	# charging
	if !character.movement.is_crouching:
		charge_timer += delta
		charge_timer = min(charge_timer, CHARGE_TIMER_MAX)
		if charge_timer >= CHARGE_TIMER_MINIMUM_THRESHOLD:
			sjanim_timer += delta / CHARGE_TIMER_MAX
			sjanim_timer = min(sjanim_timer, 1)


func charge_precentage() -> float:
	return sjanim_timer


func is_charging() -> bool:
	return charge_timer > 0


func is_locking() -> bool:
	return charge_timer > CHARGE_TIMER_MINIMUM_THRESHOLD


func is_fully_charged() -> bool:
	return charge_timer == CHARGE_TIMER_MAX
