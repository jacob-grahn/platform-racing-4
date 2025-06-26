class_name ItemManager
extends Node2D
## Manages player items, their activation and effects
##
## Handles acquisition, use, and disposal of all player items,
## including their forces and visual effects.

# kind of a hack so moving animations over to character_display doesn't break this
# todo: make this better
@onready var item_holder: Node2D = get_node("../Display/ItemHolder")

var character: Character

const RANDOM_BLOCK_ITEM := preload("res://items/random_block_item.tscn")
const ANGEL_WINGS_ITEM := preload("res://items/angel_wings_item.tscn")
const BLACK_HOLE_ITEM := preload("res://items/black_hole_item.tscn")
const ICE_WAVE_ITEM := preload("res://items/ice_wave_item.tscn")
const JETPACK_ITEM := preload("res://items/jetpack_item.tscn")
const LASER_GUN_ITEM := preload("res://items/laser_gun_item.tscn")
const LIGHTNING_ITEM := preload("res://items/lightning_item.tscn")
const PORTABLE_BLOCK_ITEM := preload("res://items/portable_block_item.tscn")
const PORTABLE_MINE_ITEM := preload("res://items/portable_mine_item.tscn")
const ROCKET_LAUNCHER_ITEM := preload("res://items/rocket_launcher_item.tscn")
const SHIELD_ITEM := preload("res://items/shield_item.tscn")
const SPEED_BURST_ITEM := preload("res://items/speed_burst_item.tscn")
const SUPER_JUMP_ITEM := preload("res://items/super_jump_item.tscn")
const SWORD_ITEM := preload("res://items/sword_item.tscn")
const TELEPORT_ITEM := preload("res://items/teleport_item.tscn")

var item: Node2D
var item_id: int = 0
var have_item: bool = false
var uses: int = 0
var using: bool = false
var has_force: bool = false
var force := Vector2.ZERO
var remove: bool = false


func _ready() -> void:
	item = null


func _physics_process(delta: float) -> void:
	get_item_force(delta)
	check_item()


# tada, the item system, not all items are fully implemented at the moment.
# it's also slightly unoptimized, i think.
func set_item_id(item_id: int, p_character: Character) -> void:
	character = p_character
	if item:
		remove_item()
	item = null
	match item_id:
		0:
			has_force = false
			uses = 1
			item = RANDOM_BLOCK_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		1:
			has_force = true
			uses = 3
			item = ANGEL_WINGS_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		2:
			has_force = false
			uses = 1
			item = BLACK_HOLE_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		3:
			has_force = false
			uses = 3
			item = ICE_WAVE_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		4:
			has_force = true
			uses = 1
			item = JETPACK_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		5:
			has_force = false
			uses = 3
			item = LASER_GUN_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		6:
			has_force = false
			uses = 1
			item = LIGHTNING_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		7:
			has_force = false
			uses = 1
			item = PORTABLE_BLOCK_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		8:
			has_force = false
			uses = 1
			item = PORTABLE_MINE_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		9:
			has_force = false
			uses = 1
			item = ROCKET_LAUNCHER_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		10:
			has_force = false
			uses = 1
			item = SHIELD_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		11:
			has_force = true
			uses = 1
			item = SPEED_BURST_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		12:
			has_force = false
			uses = 1
			item = SUPER_JUMP_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		13:
			has_force = false
			uses = 3
			item = SWORD_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character
		14:
			has_force = false
			uses = 1
			item = TELEPORT_ITEM.instantiate()
			item_holder.add_child(item)
			item.character = character


func use(delta: float) -> void:
	if uses > 0 and not using:
		_use_item()


func _use_item() -> void:
	item.activate_item()


func get_item_force(delta: float) -> Vector2:
	if item and has_force and item.using:
		force = item.get_force(delta)
		return force
	else:
		return Vector2.ZERO


func check_item() -> void:
	if item:
		if item.using:
			using = true
		else:
			using = false
		var keep: bool = item.still_have_item()
		if not keep:
			remove_item()


func _on_timeout() -> void:
	uses -= 1
	using = false


func _give_shield(player: Node2D) -> void:
	player.shielded = true


func _remove_shield(player: Node2D) -> void:
	player.shielded = false # Fixed bug: was setting to true


func remove_item() -> void:
	if item:
		item.queue_free()
		item = null
