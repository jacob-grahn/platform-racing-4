extends Item
class_name TeleportItem


func _init_item():
	uses = GameConfig.get_value("uses_teleport")

# basic teleporting works but there is no detection-
# to stop you from teleporting into a wall.
func activate_item():
	if character and !using:
		using = true
		uses -= 1
		if character.movement.facing > 0:
			character.position.x += 512
		else:
			character.position.x -= 512
		Jukebox.play_sound("teleport")


func _remove_item():
	pass
