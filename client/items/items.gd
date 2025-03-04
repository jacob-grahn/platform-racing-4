extends Node
class_name Items

var item = {}

# Called when the node enters the scene tree for the first time.
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
	item['a'] = AngelWingsItem.new()
	item['b'] = BlackHoleItem.new()
	item['i'] = IceWaveItem.new()
	item['j'] = JetpackItem.new()
	item['l'] = LaserGunItem.new()
	item['li'] = LightningItem.new()
	item['p'] = PortableBlockItem.new()
	item['po'] = PortableMineItem.new()
	# item['ra'] = RandomBlockItem.new()
	item['r'] = RocketLauncherItem.new()
	item['s'] = ShieldItem.new()
	item['sp'] = SpeedBurstItem.new()
	item['su'] = SuperJumpItem.new()
	item['sw'] = SwordItem.new()
	item['t'] = TeleportItem.new()
	
	# init
	for item_id in item:
		item[item_id].init()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
