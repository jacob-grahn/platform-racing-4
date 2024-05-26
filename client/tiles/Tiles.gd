class_name Tiles

var Sun: GDScript = preload("res://tiles/lights/Sun.gd")
var Moon: GDScript = preload("res://tiles/lights/Moon.gd")
var Firefly: GDScript = preload("res://tiles/lights/Firefly.gd")
var Gear: GDScript = preload("res://tiles/Gear.gd")

var map = {}
var sun
var moon
var firefly
var gear


func init_defaults() -> void:
	var basic1: Tile = Tile.new()
	map['0'] = basic1
	
	var basic2: Tile = Tile.new()
	map['1'] = basic2
	
	var basic3: Tile = Tile.new()
	map['2'] = basic3
	
	var basic4: Tile = Tile.new()
	map['3'] = basic4
	
	var arrow_down: Tile = Tile.new()
	arrow_down.any_side.push_back(Behaviors.push_down)
	map['5'] = arrow_down
	
	var arrow_up:Tile = Tile.new()
	arrow_up.any_side.push_back(Behaviors.push_up)
	map['6'] = arrow_up
	
	var arrow_left:Tile = Tile.new()
	arrow_left.any_side.push_back(Behaviors.push_left)
	map['7'] = arrow_left
	
	var arrow_right:Tile = Tile.new()
	arrow_right.any_side.push_back(Behaviors.push_right)
	map['8'] = arrow_right
	
	var area_switch:Tile = Tile.new()
	area_switch.area.push_back(Behaviors.ares_switch)
	map['35'] = area_switch
	
	gear = Gear.new()
	
	#
	sun = Sun.new()
	sun.init()
	map['36'] = sun
	
	#
	moon = Moon.new()
	moon.init()
	map['37'] = moon
	
	#
	firefly = Firefly.new()
	firefly.init()
	map['38'] = firefly


func on(event: String, tile_type: int, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		tile.on(event, source, target, coords)


func is_solid(tile_type: int) -> bool:
	if str(tile_type) in map:
		var tile:Tile = map[str(tile_type)]
		return tile.matter_type == Tile.SOLID
	return false


func activate(game):
	gear.activate(game)
	activate_node(game)


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
	sun.activate_tilemap(tilemap)
	moon.activate_tilemap(tilemap)
	firefly.activate_tilemap(tilemap)
