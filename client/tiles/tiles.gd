class_name Tiles

var map = {}

# PR3 non-custom block data goes like this: block: XY
# X is the style of the block. (b1 = desert, b2 = industrial, b3 = jungle, b4 = space, b5 = underwater, b = classic.)
# Y is the block ID. (0 = start, 1-4 = basics (2-4 (white, x, and waffle) are unused in pr3.), 5 = brick,
# 6 = crumble, 7 = finish, 8 = happy, 9 = ice, 10 = infinite, 11 = item, 12 = mine, 13 = move, 14 = push,
# 15 = rotateleft, 16 = rotateright, 17 = sad, 18 = safetynet, 19 = vanish, 20 = water, 21 = redteleport,
# 22 = blueteleport, 23 = yellowteleport, 24 = bounce, 25 = change, 26 = up, 27 = down, 28 = left, 29 = right)
# IMPORTANT: If the block category is classic, then the block data is just "b" followed by the block id
# (b8-b9-b10-b11). Otherwise, for numbers 0 through 9, an extra 0 is added before the block id (b108-b109-b110-b11).

func init_defaults() -> void:
	map['1'] = Tile.new()
	map['2'] = Tile.new()
	map['3'] = Tile.new()
	map['4'] = Tile.new()
	map['5'] = Brick.new()
	map['6'] = ArrowDown.new()
	map['7'] = ArrowUp.new()
	map['8'] = ArrowLeft.new()
	map['9'] = ArrowRight.new()
	map['10'] = Mine.new()
	map['11'] = ItemDispenser.new()
	map['12'] = Start.new()
	map['13'] = Bounce.new()
	map['14'] = Change.new()
	map['15'] = Tile.new()
	map['16'] = Ice.new()
	map['17'] = Finish.new()
	map['18'] = Crumble.new()
	map['19'] = Vanish.new()
	map['20'] = Move.new()
	map['21'] = Water.new()
	map['22'] = RotateClockwise.new()
	map['23'] = RotateCounterclockwise.new()
	map['24'] = Push.new()
	map['25'] = SafetyNet.new()
	map['26'] = ItemDispenserInfinite.new()
	map['27'] = Happy.new()
	map['28'] = Sad.new()
	map['29'] = Heart.new()
	map['30'] = Tile.new()
	map['31'] = EggBlock.new()
	map['32'] = BlueTeleport.new()
	map['33'] = RedTeleport.new()
	map['34'] = YellowTeleport.new()
	map['35'] = Gear.new()
	map['36'] = PresenceSwitch.new()
	map['37'] = Sun.new()
	map['38'] = Moon.new()
	map['39'] = Firefly.new()
	map['40'] = Appear.new()
	map['41'] = Mega.new()
	map['42'] = Mini.new()
	
	# init
	for tile_id in map:
		map[tile_id].init()


func on(event: String, tile_type: int, player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		tile.on(event, player, tile_map_layer, coords)
		if event == "bump":
			TileEffects.bump(player, tile_map_layer, coords)


func is_solid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID
	return false


func is_liquid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.LIQUID
	return false


func is_safe(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID && tile.is_safe
	return false


func activate_node(node: Node):
	if node is TileMapLayer:
		activate_tile_map_layer(node)
		return
		
	for child in node.get_children():
		if child is TileMapLayer:
			activate_tile_map_layer(child)
		elif child is Node2D || child is ParallaxBackground:
			activate_node(child)


func activate_tile_map_layer(tile_map_layer: TileMapLayer):
	for tile_id in map:
		map[tile_id].activate_tile_map_layer(tile_map_layer)


func clear():
	for tile_id in map:
		map[tile_id].clear()
