extends Node2D
class_name ShieldItem

# @onready var shield = get_node("../../../Shield")
@onready var Shield = $Shield
@onready var character = get_node("../../..")
var using: bool = false
var remove: bool = false
var timer: float = 0
var uses: int = 1


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
		character.shielded = false
		uses - 1
		remove = true


func activate_item():
	if !using:
		using = true
		Shield.visible = true
		character.shielded = true


func still_have_item():
	if !remove:
		return true
	else:
		return false


func _exit_tree():
	character.shielded = false
