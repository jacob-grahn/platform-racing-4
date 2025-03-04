extends Node2D
class_name BlackHoleItem

@onready var hole = load("res://item_effects/black_hole.tscn")
@onready var character = get_node("../../..")
@onready var spawn = get_node("../../../..")
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
		spawn_hole()
		uses -= 1

func spawn_hole():
	var blackhole = hole.instantiate()
	spawn.add_child.call_deferred(blackhole)
	blackhole.dir = 0
	blackhole.spawnpos = global_position
	blackhole.spawnrot = 0
	blackhole.scale.x = character.display.scale.x
	
func still_have_item():
	if !remove:
		return true
	else:
		return false
