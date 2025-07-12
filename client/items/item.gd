class_name ItemManager
extends Node2D
## Manages player items, their activation and effects
##
## Handles acquisition, use, and disposal of all player items,
## including their forces and visual effects.

# kind of a hack so moving animations over to character_display doesn't break this
# todo: make this better
var item_holder: Node2D

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
			uses = GameConfig.get_value("uses_random_block")
			item = RANDOM_BLOCK_ITEM.instantiate()
		1:
			has_force = true
			uses = GameConfig.get_value("uses_angel_wings")
			item = ANGEL_WINGS_ITEM.instantiate()
		2:
			has_force = false
			uses = GameConfig.get_value("uses_black_hole")
			item = BLACK_HOLE_ITEM.instantiate()
		3:
			has_force = false
			uses = GameConfig.get_value("uses_ice_wave")
			item = ICE_WAVE_ITEM.instantiate()
		4:
			has_force = true
			uses = GameConfig.get_value("uses_jetpack")
			item = JETPACK_ITEM.instantiate()
		5:
			has_force = false
			uses = GameConfig.get_value("uses_laser_gun")
			item = LASER_GUN_ITEM.instantiate()
		6:
			has_force = false
			uses = GameConfig.get_value("uses_lightning")
			item = LIGHTNING_ITEM.instantiate()
		7:
			has_force = false
			uses = GameConfig.get_value("uses_portable_block")
			item = PORTABLE_BLOCK_ITEM.instantiate()
		8:
			has_force = false
			uses = GameConfig.get_value("uses_portable_mine")
			item = PORTABLE_MINE_ITEM.instantiate()
		9:
			has_force = false
			uses = GameConfig.get_value("uses_rocket_launcher")
			item = ROCKET_LAUNCHER_ITEM.instantiate()
		10:
			has_force = false
			uses = GameConfig.get_value("uses_shield")
			item = SHIELD_ITEM.instantiate()
		11:
			has_force = true
			uses = GameConfig.get_value("uses_speed_burst")
			item = SPEED_BURST_ITEM.instantiate()
		12:
			has_force = false
			uses = GameConfig.get_value("uses_super_jump")
			item = SUPER_JUMP_ITEM.instantiate()
		13:
			has_force = false
			uses = GameConfig.get_value("uses_sword")
			item = SWORD_ITEM.instantiate()
		14:
			has_force = false
			uses = GameConfig.get_value("uses_teleport")
			item = TELEPORT_ITEM.instantiate()
	if item:
		item.character = character
		item_holder.add_child(item)


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
