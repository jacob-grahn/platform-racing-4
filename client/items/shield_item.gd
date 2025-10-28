extends Item
class_name ShieldItem

@onready var shield_sprite = $Shield
var shield_timer = Timer.new()


func _ready() -> void:
	shield_timer.connect("timeout", _shield_timeout)
	shield_timer.process_callback = 0
	shield_timer.one_shot = true


func _init_item() -> void:
	uses = GameConfig.get_value("uses_shield")
	shield_sprite.visible = false

	
func activate_item():
	if character and !using:
		using = true
		shield_sprite.visible = true
		character.shielded = true
		shield_timer.start(GameConfig.get_value("shield_duration"))
		Jukebox.play_sound("shield1")


func _shield_timeout():
	shield_sprite.visible = false
	if character:
		character.shielded = false
	uses -= 1


func _remove_item():
	shield_sprite.visible = false
	if character:
		character.shielded = false
