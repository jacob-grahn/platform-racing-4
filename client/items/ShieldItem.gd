extends Node2D
class_name ShieldItem

@onready var Shield = $Shield
var using: bool = false
var remove: bool = false
var timer: float = 0


func _ready():
	timer = 10.0
	Shield.visible = false
	
func _physics_process(delta):
	check_if_used()
	if using:
		timer -= delta

func check_if_used():
	if timer > 0:
		remove = false
	else:
		get_parent().get_parent().shielded = false
		get_parent().uses - 1
		remove = true

func activate_item():
	if !using:
		using = true
		Shield.visible = true
		get_parent().get_parent().shielded = true

func still_have_item():
	if !remove:
		return true
	else:
		return false

func _exit_tree():
	get_parent().get_parent().shielded = false
