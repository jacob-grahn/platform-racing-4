extends Node2D
class_name PortableMineItem

var using: bool = false
var remove: bool = false

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

func still_have_item():
	if !remove:
		return true
	else:
		return false
