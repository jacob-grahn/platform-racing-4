extends Tile
class_name EggBlock

const EGG_ENEMY = preload("res://tiles/egg/egg_enemy.tscn")

var timer: Timer
var egg_atlas_coords: Vector2i = Vector2i(0, 3)


func init():
	matter_type = Tile.GAS
	is_safe = false


func activate_tilemap(tile_map: TileMap) -> void:
	# add_timer()
	
	# add an egg enemy at the tile position
	var coord_list: Array = tile_map.get_used_cells_by_id(0, 0, egg_atlas_coords)
	for coords: Vector2i in coord_list:
		add_egg_enemy(tile_map, coords)
	
	# make the egg tile invisible
	if len(coord_list) > 0:
		var coords: Vector2i = coord_list[0]
		var data = tile_map.get_cell_tile_data(0, coords)
		data.modulate = Color(1.0, 1.0, 1.0, 0.0)


func add_egg_enemy(tile_map: TileMap, coords: Vector2i) -> void:
	var egg_enemy = EGG_ENEMY.instantiate()
	var depth = Globals.Helpers.get_depth(tile_map)
	egg_enemy.position = get_center_position(tile_map, coords)
	tile_map.add_child(egg_enemy)
	egg_enemy.set_depth(depth)


func add_timer() -> void:
	if timer:
		return
	timer = Timer.new()
	Globals.Helpers.add_child(timer)
	timer.wait_time = 1.0
	timer.connect("timeout", _on_timeout)
	timer.start()


func remove_timer() -> void:
	if timer:
		timer.stop()
		Globals.Helpers.remove_child(timer)
		timer = null


func _on_timeout():
	pass


func clear():
	remove_timer()
