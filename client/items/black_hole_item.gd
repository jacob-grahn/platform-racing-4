extends Item
class_name BlackHoleItem

@onready var hole = load("res://item_effects/black_hole.tscn")


func _init_item():
	uses = GameConfig.get_value("uses_black_hole")


func activate_item():
	if character and !using:
		using = true
		spawn_hole()
		uses -= 1


func spawn_hole():
	var blackhole = hole.instantiate()
	spawn.add_child.call_deferred(blackhole)
	blackhole.dir = 0
	blackhole.spawnpos = global_position
	blackhole.spawnrot = 0
	blackhole.scale.x = character.movement.facing
	Jukebox.play_sound("blackhole")


func _remove_item():
	pass
