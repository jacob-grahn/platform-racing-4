class_name Items
extends Node
## Manager for game items and their initialization
##
## Registry for all available game items with their initialization
## and lookup functionality. Currently unused but prepared for future item blocks.

var items := {}


func _ready() -> void:
	pass # Replace with function body.


# whole script is unused at this point.
# copied over from "tiles" list, so nothing has been-
# changed to just add allowed items to item blocks yet.

# uses the item list found in PR3.
# PR2's item list goes something like this.

# 1 - lasergun
# 2 - mine
# 3 - lightning
# 4 - teleport
# 5 - superjump
# 6 - jetpack
# 7 - speedburst
# 8 - sword
# 9 - icewave

# if you want to add reverse compatibility-
# for item lists in PR2/PR3 levels, go ahead.

func init_defaults() -> void:
	items["a"] = AngelWingsItem.new()
	items["b"] = BlackHoleItem.new()
	items["i"] = IceWaveItem.new()
	items["j"] = JetpackItem.new()
	items["l"] = LaserGunItem.new()
	items["li"] = LightningItem.new()
	items["p"] = PortableBlockItem.new()
	items["po"] = PortableMineItem.new()
	# items["ra"] = RandomBlockItem.new()
	items["r"] = RocketLauncherItem.new()
	items["s"] = ShieldItem.new()
	items["sp"] = SpeedBurstItem.new()
	items["su"] = SuperJumpItem.new()
	items["sw"] = SwordItem.new()
	items["t"] = TeleportItem.new()
	
	# init
	for item_id in items:
		items[item_id].init()


func _process(delta: float) -> void:
	pass
