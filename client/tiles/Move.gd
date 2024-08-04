extends Tile
class_name Move

const PLAN: String = "plan"
const MOVE: String = "move"

var move_atlas_coords = Vector2i(9, 1)
var tile_maps = []
var connected_objects = []
var timer: Timer
var mode = PLAN


func init():
	matter_type = Tile.SOLID
	stand.push_back(move_track)


func activate_tilemap(tile_map: TileMap) -> void:
	tile_maps.push_back(tile_map)
	add_timer()


func move_track(player: Node2D, tile_map: TileMap, coords: Vector2i):
	connected_objects.push_back({
		"object": player,
		"tile_map": tile_map,
		"coords": coords,
		"ms": Time.get_ticks_msec()
	})


func remove_stale_connected_objects() -> void:
	var ms = Time.get_ticks_msec()
	connected_objects = connected_objects.filter(func(co): return ms - co.ms < 50) 
	

func do_plan():
	for tile_map: TileMap in tile_maps:
		var coord_list: Array = tile_map.get_used_cells_by_id(0, 0, move_atlas_coords)
		for coords: Vector2i in coord_list:
			var rand = randi_range(0, 3)
			var dir = Vector2i(0, 0)
			if rand == 0:
				dir.x = 1
			elif rand == 1:
				dir.x = -1
			elif rand == 2:
				dir.y = 1
			elif rand == 3:
				dir.y = -1


func do_move():
	remove_stale_connected_objects()
	
	for tile_map: TileMap in tile_maps:
		var coord_list: Array = tile_map.get_used_cells_by_id(0, 0, move_atlas_coords)
		for coords: Vector2i in coord_list:
			var rand = randi_range(0, 3)
			var dir = Vector2i(0, 0)
			if rand == 0:
				dir.x = 1
			elif rand == 1:
				dir.x = -1
			elif rand == 2:
				dir.y = 1
			elif rand == 3:
				dir.y = -1
			
			# bail if there is something in the way
			if tile_map.get_cell_atlas_coords(0, coords + dir) != Vector2i(-1, -1):
				continue
			
			# move!
			tile_map.set_cell(-1, coords)
			tile_map.set_cell(0, coords + dir, 0, move_atlas_coords)
			
			# move connected objects
			for co in connected_objects:
				if co.tile_map == tile_map && co.coords == coords:
					co.object.position += Vector2(dir * Settings.tile_size)
					break


func add_timer() -> void:
	if timer:
		return
	timer = Timer.new()
	Helpers.add_child(timer)
	timer.wait_time = 0.5
	timer.connect("timeout", _on_timeout)
	timer.start()


func remove_timer() -> void:
	if timer:
		timer.stop()
		Helpers.remove_child(timer)
		timer = null


func _on_timeout():
	if mode == PLAN:
		do_plan()
		mode = MOVE
	elif mode == MOVE:
		do_move()
		mode = PLAN


func clear():
	tile_maps = []
	connected_objects = []
	remove_timer()
	mode = PLAN
