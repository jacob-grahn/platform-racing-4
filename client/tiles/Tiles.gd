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
	
	# start
	map['12'] = Start.new()
	
	# bounce
	map['13'] = Bounce.new()
	
	var area_switch:Tile = Tile.new()
	area_switch.area.push_back(Behaviors.ares_switch)
	map['36'] = area_switch
	
	# gear
	map['34'] = Gear.new()
	
	# lights
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
			bump(player, tilemap, coords)


func is_solid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID
	return false


func activate_node(node: Node2D):
	if node is TileMap:
		activate_tilemap(node)
		return
		
	for child in node.get_children():
		if child is TileMap:
			activate_tilemap(child)
		elif child is Node2D:
			activate_node(child)


func activate_tilemap(tilemap: TileMap):
	for tile_id in map:
		map[tile_id].activate_tilemap(tilemap)


var ShatterEffect = preload("res://tile_effects/shatter_effect/ShatterEffect.tscn")
func shatter(tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var shatter_effect = ShatterEffect.instantiate()
	shatter_effect.position = coords * Settings.tile_size
	shatter_effect.add_pieces(tile_atlas, atlas_coords)
	tilemap.get_parent().add_child(shatter_effect)
	
	tilemap.set_cell(-1, coords)


var BumpEffect = preload("res://tile_effects/bump_effect/BumpEffect.tscn")
func bump(player: Node2D, tilemap: TileMap, coords: Vector2i):
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords == Vector2i(-1, -1):
		return
		
	var atlas = tilemap.tile_set.get_source(0).texture
	var node = tilemap.get_parent()
	var effect_name = str(coords.x) + "-" + str(coords.y) + "-bump"
	var existing_bump_effect = node.get_node(effect_name)
	if existing_bump_effect:
		existing_bump_effect.get_node("AnimationPlayer").seek(0.1)
		return 
		
	var bump_effect = BumpEffect.instantiate()
	bump_effect.name = effect_name
	tilemap.add_child(bump_effect)
	bump_effect.position = coords * Settings.tile_size + Settings.tile_size_half
	bump_effect.rotation = player.rotation - tilemap.global_rotation
	bump_effect.set_tile(atlas, atlas_coords, -bump_effect.rotation)
