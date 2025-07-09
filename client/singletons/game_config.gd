extends Node

var default_values: Dictionary = {
	# Player Movement
	"player_speed": 490.0,
	"player_jump_velocity": -155.0,
	"player_swim_up_velocity_multiplier": 7.0,
	"player_traction": 4000.0,
	"player_friction": 0.1,
	"player_swimming_friction": 2.0,
	"player_jump_velocity_multiplier": 0.75,
	"player_coyote_jump_time": 10.0,
	"player_wall_slide_friction": 0.15,
	"player_wall_jump_horizontal_force": 400.0,
	"player_wall_jump_vertical_force": -250.0,
	"player_wall_slide_friction_decay_time": 0.25,
	"player_frozen_duration": 3.0,

	# Super Jump
	"super_jump_velocity": -3500.0,
	"super_jump_charge_time": 1.5,
	"super_jump_min_charge_threshold": 0.5,

	# Other Player Stats
	"invincibility_duration": 5.0,
	"lightbreak_speed": 200000.0,

	# Camera
	"camera_zoom_speed": 0.6,
	"camera_max_zoom": 0.5,
	"camera_min_zoom": 0.4,
	"camera_zoom_smoothing": 0.1,
	"camera_position_smoothing": 0.333,

	# Items - Uses
	"uses_angel_wings": 3,
	"uses_black_hole": 1,
	"uses_ice_wave": 3,
	"uses_jetpack": 1,
	"uses_laser_gun": 3,
	"uses_lightning": 1,
	"uses_portable_block": 1,
	"uses_portable_mine": 1,
	"uses_random_block": 1,
	"uses_rocket_launcher": 1,
	"uses_shield": 1,
	"uses_speed_burst": 1,
	"uses_super_jump": 1,
	"uses_sword": 3,
	"uses_teleport": 1,

	# Items - Effects
	"speed_burst_duration": 6.0,
	"speed_burst_multiplier": 2.0,
	"shield_duration": 10.0,
	"jetpack_duration": 11.0, # this is 660 frames, so 11 seconds at 60fps
	"rocket_lifetime": 3.3,
	"ice_wave_speed": 800.0,
	"ice_wave_lifetime": 2.5,
	"laser_bullet_speed": 4800.0,
	"laser_bullet_lifetime": 3.3,
	"black_hole_lifetime": 10.3,
	"sword_slash_lifetime": 0.2,
}

var override_values: Dictionary = {}


func get_value(key: String):
	if override_values.has(key):
		return override_values[key]
	return default_values.get(key)


func import_overrides(new_overrides: Dictionary):
	override_values = new_overrides.duplicate(true)


func export_overrides() -> Dictionary:
	return override_values.duplicate(true)


func clear_overrides():
	override_values.clear()
