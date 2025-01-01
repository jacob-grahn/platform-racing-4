extends Node2D
class_name TeleportItem

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

# basic teleporting works but there is no detection-
# to stop you from teleporting into a wall.

func activate_item():
	if !using:
		using = true
		get_parent().uses -= 1
		if get_parent().get_parent().display.scale.x > 0:
			get_parent().get_parent().position.x += 512
		else:
			get_parent().get_parent().position.x -= 512

func still_have_item():
	if !remove:
		return true
	else:
		return false
