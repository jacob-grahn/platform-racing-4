extends Item
class_name AngelWingsItem

@onready var animations: AnimationPlayer = $Animations
var animation_timer = Timer.new()


func _ready():
	animation_timer.connect("timeout", _play_idle_animation)
	animation_timer.process_callback = 0
	animation_timer.one_shot = true


func _init_item():
	uses = GameConfig.get_value("uses_angel_wings")


func _physics_process(delta):
	if character:
		if using:
			if character.velocity.y >= 0:
				character.velocity.y = 0
			if character.velocity.y >= -3000:
				force = Vector2(100, -60)
			else:
				force = Vector2(100, 0)
		else:
			force = Vector2(0, 0)


func _play_idle_animation():
	animations.play("idle")


func activate_item():
	if character and !using:
		using = true
		animations.stop()
		animations.play("flap")
		animation_timer.start(animations.get_current_animation_length())
		reload_timer.start(1)
		Jukebox.play_sound("wingflap")


func _remove_item():
	animation_timer.stop()
	_play_idle_animation()
