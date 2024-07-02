class_name Tiles

var map = {}


func init_defaults() -> void:
	# basic
	map['1'] = Tile.new()
	map['2'] = Tile.new()
	map['3'] = Tile.new()
	map['4'] = Tile.new()
	
	# brick
	map['5'] = Brick.new()
	
	# arrow
	map['6'] = ArrowDown.new()
	map['7'] = ArrowUp.new()
	map['8'] = ArrowLeft.new()
	map['9'] = ArrowRight.new()
	
	# more
	map['12'] = Start.new()
	map['13'] = Bounce.new()
	map['35'] = PresenceSwitch.new()
	map['34'] = Gear.new()
	
	# lights
	map['36'] = Sun.new()
	map['37'] = Moon.new()
	map['38'] = Firefly.new()
	
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
