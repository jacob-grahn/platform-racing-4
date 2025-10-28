extends Item
class_name JetpackItem

@onready var Exhaust1 = $Exhaust1
@onready var JetpackFire1 = $JetpackFire1
@onready var Exhaust2 = $Exhaust2
@onready var JetpackFire2 = $JetpackFire2
var fuelon: bool = false
var jetpack_timer: float = 0.0
var exhaustscale: float = 0.0
var jetpackfirescale: float = 1.0


func _init_item():
	uses = GameConfig.get_value("uses_jetpack")
	jetpack_timer = GameConfig.get_value("jetpack_duration")


func _process(delta):
	if character:
		if !character.movement.hurt and Input.is_action_pressed("item"):
			using = true
			fuelon = true
		else:
			using = false
			fuelon = false
		if jetpack_timer > 0:
			if fuelon:
				if character.velocity.y < -700:
					force = Vector2(0, -40)
				elif character.velocity.y <= 0:
					force = Vector2(0, -65)
				else:
					force = Vector2(0, -75)
				jetpack_timer -= 1
				exhaustscale = randf_range(0.5, 1.0)
				Exhaust1.modulate = Color(1.0, 1.0, 1.0, exhaustscale)
				Exhaust2.modulate = Color(1.0, 1.0, 1.0, exhaustscale)
				jetpackfirescale = randf_range(0.1, 0.5)
				JetpackFire1.scale.y = jetpackfirescale
				JetpackFire2.scale.y = jetpackfirescale
				Exhaust1.visible = true
				JetpackFire1.visible = true
				Exhaust2.visible = true
				JetpackFire2.visible = true
			else:
				force = Vector2(0, 0)
				Exhaust1.visible = false
				JetpackFire1.visible = false
				Exhaust2.visible = false
				JetpackFire2.visible = false
		else:
			uses = 0


func activate_item():
	pass


func _remove_item():
	pass
