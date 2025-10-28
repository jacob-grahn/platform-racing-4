extends Item
class_name SuperJumpItem


func _init_item():
	uses = GameConfig.get_value("uses_super_jump")


func activate_item():
	if character and !using:
		using = true
		character.velocity.y -= 5000
		Jukebox.play_sound("superjump")
		uses -= 1


func _remove_item():
	pass
