extends Node2D
class_name ItemManager

# kind of a hack so moving animations over to character_display doesn't break this
# todo: make this better
@onready var item_holder: Node2D = get_node("../Display/ItemHolder")

const RANDOM_BLOCK_ITEM = preload("res://items/RandomBlockItem.tscn")
const ANGEL_WINGS_ITEM = preload("res://items/AngelWingsItem.tscn")
const BLACK_HOLE_ITEM = preload("res://items/BlackHoleItem.tscn")
const ICE_WAVE_ITEM = preload("res://items/IceWaveItem.tscn")
const JETPACK_ITEM = preload("res://items/JetpackItem.tscn")
const LASER_GUN_ITEM = preload("res://items/LaserGunItem.tscn")
const LIGHTNING_ITEM = preload("res://items/LightningItem.tscn")
const PORTABLE_BLOCK_ITEM = preload("res://items/PortableBlockItem.tscn")
const PORTABLE_MINE_ITEM = preload("res://items/PortableMineItem.tscn")
const ROCKET_LAUNCHER_ITEM = preload("res://items/RocketLauncherItem.tscn")
const SHIELD_ITEM = preload("res://items/ShieldItem.tscn")
const SPEED_BURST_ITEM = preload("res://items/SpeedBurstItem.tscn")
const SUPER_JUMP_ITEM = preload("res://items/SuperJumpItem.tscn")
const SWORD_ITEM = preload("res://items/SwordItem.tscn")
const TELEPORT_ITEM = preload("res://items/TeleportItem.tscn")

var item = Node2D
var item_id: int = 0
var have_item: bool = false
var uses: int = 0
var using: bool = false
var has_force: bool = false
var force = Vector2(0, 0)
var remove: bool = false

func _physics_process(delta):
	get_item_force(delta)
	check_item()

func _ready():
	item = null
	
# tada, the item system, not all items are fully implemented at the moment.
# it's also slightly unoptimized, i think.
func set_item_id(item_id: int):
	if item:
		remove_item()
	item = null
	match item_id:
		0: has_force = false; uses = 1; item = RANDOM_BLOCK_ITEM.instantiate(); item_holder.add_child(item)
		1: has_force = true; uses = 3; item = ANGEL_WINGS_ITEM.instantiate(); item_holder.add_child(item)
		2: has_force = false; uses = 1; item = BLACK_HOLE_ITEM.instantiate(); item_holder.add_child(item)
		3: has_force = false; uses = 3; item = ICE_WAVE_ITEM.instantiate(); item_holder.add_child(item)
		4: has_force = true; uses = 1; item = JETPACK_ITEM.instantiate(); item_holder.add_child(item)
		5: has_force = false; uses = 3; item = LASER_GUN_ITEM.instantiate(); item_holder.add_child(item)
		6: has_force = false; uses = 1; item = LIGHTNING_ITEM.instantiate(); item_holder.add_child(item)
		7: has_force = false; uses = 1; item = PORTABLE_BLOCK_ITEM.instantiate(); item_holder.add_child(item)
		8: has_force = false; uses = 1; item = PORTABLE_MINE_ITEM.instantiate(); item_holder.add_child(item)
		9: has_force = false; uses = 1; item = ROCKET_LAUNCHER_ITEM.instantiate(); item_holder.add_child(item)
		10: has_force = false; uses = 1; item = SHIELD_ITEM.instantiate(); item_holder.add_child(item)
		11: has_force = true; uses = 1; item = SPEED_BURST_ITEM.instantiate(); item_holder.add_child(item)
		12: has_force = true; uses = 1; item = SUPER_JUMP_ITEM.instantiate(); item_holder.add_child(item)
		13: has_force = false; uses = 3; item = SWORD_ITEM.instantiate(); item_holder.add_child(item)
		14: has_force = false; uses = 1; item = TELEPORT_ITEM.instantiate(); item_holder.add_child(item)

func use(delta: float):
	if uses > 0 and !using:
		_use_item()

func _use_item():
	item.activate_item()

func get_item_force(delta: float):
	if item and has_force and item.using:
		force = item.get_force(delta)
		return force
	else:
		return Vector2(0, 0)

func check_item():
	if item:
		if item.using:
			using = true
		else:
			using = false
		var keep: bool = item.still_have_item()
		if !keep:
			remove_item()

func _on_timeout():
	uses -= 1
	using = false
	
func _give_shield(player: Node2D):
	player.shielded = true
	
func _remove_shield(player: Node2D):
	player.shielded = true

func remove_item():
	if item:
		item.queue_free()
		item = null
