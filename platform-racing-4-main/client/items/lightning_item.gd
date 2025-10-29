extends Node2D
class_name LightningItem

var using: bool = false
var remove: bool = false
var uses: int = 1

func _physics_process(delta):
	check_if_used()

func _ready():
	pass

func check_if_used():
	if uses < 1:
		remove = true

func activate_item():
	if !using:
		using = true
		uses -= 1

func still_have_item():
	if !remove:
		return true
	else:
		return false
