extends Node2D
class_name SuperJumpItem

var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)

func _physics_process(delta):
	check_if_used()

func _ready():
	pass

func check_if_used():
	if get_parent().uses < 1:
		remove = true

func activate_item():
	if !using:
		using = true
		get_parent().uses -= 1

func get_force(delta: float):
	if using:
		return Vector2(0, -5000)
	else:
		return Vector2(0, 0)

func still_have_item():
	if !remove:
		return true
	else:
		return false
