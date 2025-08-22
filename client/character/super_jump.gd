class_name SuperJump
## Handles the super jump ability charging and execution.
## Manages charge timers and provides state information.

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
		if !character.movement.is_crouching and charge_timer >= GameConfig.get_value("super_jump_min_charge_threshold"): 
			character.velocity += Vector2(0, GameConfig.get_value("super_jump_velocity")).rotated(character.rotation) * (
					(charge_timer - GameConfig.get_value("super_jump_min_charge_threshold")) / 
					(GameConfig.get_value("super_jump_charge_time") - GameConfig.get_value("super_jump_min_charge_threshold")))
		if charge_timer >= GameConfig.get_value("super_jump_min_charge_threshold"):
			character.play_sound(AudioManager.SUPERJUMP, linear_to_db(sjanim_timer))
		charge_timer = 0
		sjanim_timer = 0
		return
		
	# charging
	if !character.movement.is_crouching:
		charge_timer += delta
		charge_timer = min(charge_timer, GameConfig.get_value("super_jump_charge_time"))
		if charge_timer >= GameConfig.get_value("super_jump_min_charge_threshold"):
			sjanim_timer += delta / GameConfig.get_value("super_jump_charge_time")
			sjanim_timer = min(sjanim_timer, 1)


func charge_precentage() -> float:
	return sjanim_timer


func is_charging() -> bool:
	return charge_timer > 0


func is_locking() -> bool:
	return charge_timer > GameConfig.get_value("super_jump_min_charge_threshold")


func is_fully_charged() -> bool:
	return charge_timer == GameConfig.get_value("super_jump_charge_time")
