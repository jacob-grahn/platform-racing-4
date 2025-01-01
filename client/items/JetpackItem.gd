extends Node2D
class_name JetpackItem

@onready var Exhaust1 = $Exhaust1
@onready var JetpackFire1 = $JetpackFire1
@onready var Exhaust2 = $Exhaust2
@onready var JetpackFire2 = $JetpackFire2
@onready var character = get_node("../../..")
var using: bool = false
var fuelon: bool = false
var remove: bool = false
var boost = Vector2(0, 0)
var timer: int = 0
var exhaustscale: float = 0.0
var jetpackfirescale: float = 0.0
var uses: int = 1

func _physics_process(delta):
	item_button_pressed()
	if timer > 0:
		if fuelon:
			if character.velocity.y < -700:
				boost = Vector2(0, -40)
			elif character.velocity.y <= 0:
				boost = Vector2(0, -65)
			else:
				boost = Vector2(0, -75)
			timer -= 1
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
			boost = Vector2(0, 0)
			Exhaust1.visible = false
			JetpackFire1.visible = false
			Exhaust2.visible = false
			JetpackFire2.visible = false
	else:
		uses = 0
		remove = true
	update_animation()

func _ready():
	timer = 660
	jetpackfirescale = 1.0
	uses = 1

func item_button_pressed():
	if !character.hurt and Input.is_action_pressed("item"):
		using = true
		fuelon = true
	else:
		using = false
		fuelon = false

func update_animation():
	if using:
		pass
	else:
		pass

func activate_item():
	pass

func get_force(delta: float):
	if using:
		return boost
	else:
		return Vector2(0, 0)

func still_have_item():
	if !remove:
		return true
	else:
		return false
