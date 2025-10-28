extends Item
class_name SpeedBurstItem

var speedburst_timer = Timer.new()


func _ready() -> void:
	speedburst_timer.connect("timeout", _speedburst_timeout)
	speedburst_timer.process_callback = 0
	speedburst_timer.one_shot = true


func _init_item():
	uses = GameConfig.get_value("uses_speed_burst")


func activate_item():
	if character and !using:
		using = true
		character.speed_particles.emitting = true
		character.movement.speedburst_boost = GameConfig.get_value("speed_burst_multiplier")
		speedburst_timer.start(GameConfig.get_value("speed_burst_duration"))
		Jukebox.play_sound("speedup")


func _speedburst_timeout():
	using = false
	if character:
		character.speed_particles.emitting = false
		character.movement.speedburst_boost = 1.0
	uses -= 1
	Jukebox.play_sound("slowdown")


func _remove_item():
	if character:
		character.speed_particles.emitting = false
		character.movement.speedburst_boost = 1.0
	if using:
		Jukebox.play_sound("slowdown")
