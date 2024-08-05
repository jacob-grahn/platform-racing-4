class_name Tiles

var map = {}


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
	map['11'] = ItemDispsnser.new()
	map['12'] = Start.new()
	map['13'] = Bounce.new()
	map['14'] = Tile.new()
	map['15'] = Tile.new()
	map['16'] = Ice.new()
	map['17'] = Tile.new()
	map['18'] = Tile.new()
	map['19'] = Vanish.new()
	map['20'] = Move.new()
	map['21'] = Tile.new()
	map['22'] = RotateClockwise.new()
	map['23'] = RotateCounterclockwise.new()
	map['24'] = Push.new()
	map['25'] = SafetyNet.new()
	map['26'] = Tile.new()
	map['27'] = Tile.new()
	map['28'] = Tile.new()
	map['29'] = Tile.new()
	map['30'] = Tile.new()
	map['31'] = Tile.new()
	map['32'] = BlueTeleport.new()
	map['33'] = RedTeleport.new()
	map['34'] = YellowTeleport.new()
	map['35'] = Gear.new()
	map['36'] = PresenceSwitch.new()
	map['37'] = Sun.new()
	map['38'] = Moon.new()
	map['39'] = Firefly.new()
	
	# init
	for tile_id in map:
		map[tile_id].init()


func on(event: String, tile_type: int, player: Node2D, tilemap: TileMap, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		tile.on(event, player, tilemap, coords)
		if event == "bump":
			TileEffects.bump(player, tilemap, coords)


func is_solid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID
	return false


func is_safe(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID && tile.is_safe
	return false


func activate_node(node: Node):
	if node is TileMap:
		activate_tilemap(node)
		return
		
	for child in node.get_children():
		if child is TileMap:
			activate_tilemap(child)
		elif child is Node2D || child is ParallaxBackground:
			activate_node(child)


func activate_tilemap(tilemap: TileMap):
	for tile_id in map:
		map[tile_id].activate_tilemap(tilemap)


func clear():
	for tile_id in map:
		map[tile_id].clear()
