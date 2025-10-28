extends Item
class_name LightningItem


func _init_item():
	uses = GameConfig.get_value("uses_lightning")


func activate_item():
	if character and !using:
		using = true
		uses -= 1
		Jukebox.play_sound("lightning")


func _remove_item():
	pass
