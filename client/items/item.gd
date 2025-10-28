extends Node2D
class_name Item
## Manages player items, their activation and effects
##
## Handles acquisition, use, and disposal of all player items,
## including their forces and visual effects.

# kind of a hack so moving animations over to character_display doesn't break this
# TODO: make this better
@onready var angelwings = $AngelWingsItem
@onready var blackhole = $BlackHoleItem
@onready var icewave = $IceWaveItem
@onready var jetpack = $JetpackItem
@onready var lasergun = $LaserGunItem
@onready var lightning = $LightningItem
@onready var portableblock = $PortableBlockItem
@onready var portablemine = $PortableMineItem
@onready var rocketlauncher = $RocketLauncherItem
@onready var shield = $ShieldItem
@onready var speedburst = $SpeedBurstItem
@onready var superjump = $SuperJumpItem
@onready var sword = $SwordItem
@onready var teleport = $TeleportItem
var character: Character
var spawn: Node2D
var item_holder: Node2D
var item: Node2D = null
var item_id: int = 0
var item_pool: Array = []
var uses: int = 0
var reload_timer = Timer.new()
var using: bool = false
var has_force: bool = false
var force := Vector2.ZERO


func _ready() -> void:
	reload_timer.connect("timeout", _timeout)
	reload_timer.process_callback = 0
	reload_timer.wait_time = 0.0
	reload_timer.one_shot = true
	var layer = Game.get_target_block_layer_node()
	spawn = layer.get_node("Projectiles")
	item_pool = [null, angelwings, blackhole, icewave, jetpack, lasergun, lightning, portableblock,
	portablemine, rocketlauncher, shield, speedburst, superjump, sword, teleport]


func init(p_character: Character):
	character = p_character


func _process(delta: float) -> void:
	if item and uses <= 0:
		item._remove_item()


# tada, the item system, not all items are fully implemented at the moment.
# it's also slightly unoptimized, i think.
func set_item_id(item_id: int) -> void:
	if character:
		if item:
			remove_item()
		if item_id > 0 and item_id < item_pool.size():
			item = item_pool[item_id]
			item._init_item()
			item.visible = true


func try_to_use(delta: float) -> void:
	if item and uses > 0 and not using:
		_use_item()


func _use_item() -> void:
	item.activate_item()


func _timeout() -> void:
	uses -= 1
	using = false


func remove_item() -> void:
	if item:
		item._remove_item()
		item.visible = false
		reload_timer.stop()
		uses = 0
		using = false
		item = null
