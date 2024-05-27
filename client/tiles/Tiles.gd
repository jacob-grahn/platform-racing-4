class_name Tiles

var Sun: GDScript = preload("res://tiles/lights/Sun.gd")
var Moon: GDScript = preload("res://tiles/lights/Moon.gd")
var Firefly: GDScript = preload("res://tiles/lights/Firefly.gd")
var Gear: GDScript = preload("res://tiles/Gear.gd")
var ArrowUp: GDScript = preload("res://tiles/arrows/ArrowUp.gd")
var ArrowRight: GDScript = preload("res://tiles/arrows/ArrowRight.gd")
var ArrowDown: GDScript = preload("res://tiles/arrows/ArrowDown.gd")
var ArrowLeft: GDScript = preload("res://tiles/arrows/ArrowLeft.gd")

var map = {}
var sun
var moon
var firefly
var gear


func init_defaults() -> void:
	# basic
	map['0'] = Tile.new()
	map['1'] = Tile.new()
	map['2'] = Tile.new()
	map['3'] = Tile.new()
	
	# arrow
	map['5'] = ArrowDown.new()
	map['6'] = ArrowUp.new()
	map['7'] = ArrowLeft.new()
	map['8'] = ArrowRight.new()
	
	var area_switch:Tile = Tile.new()
	area_switch.area.push_back(Behaviors.ares_switch)
	map['35'] = area_switch
	
	gear = Gear.new()
	
	# lights
	sun = Sun.new()
	map['36'] = sun
	moon = Moon.new()
	map['37'] = moon
	firefly = Firefly.new()
	map['38'] = firefly
	
	# init
	for tile_id in map:
		map[tile_id].init()


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
