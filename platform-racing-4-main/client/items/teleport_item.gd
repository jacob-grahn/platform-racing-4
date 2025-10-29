extends Node2D
class_name TeleportItem

var using: bool = false
var remove: bool = false
var boost = Vector2(0, 0)
var uses: int = 1
@onready var character = get_node("../../..")

func _physics_process(delta):
	check_if_used()

func _ready():
	pass

func check_if_used():
	if uses < 1:
		remove = true

# basic teleporting works but there is no detection-
# to stop you from teleporting into a wall.

func activate_item():
	if !using:
		using = true
		uses -= 1
		if character.display.scale.x > 0:
			character.position.x += 512
		else:
			character.position.x -= 512

func still_have_item():
	if !remove:
		return true
	else:
		return false
