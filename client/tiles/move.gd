extends Tile
class_name Move

const PLAN: String = "plan"
const MOVE: String = "move"

var move_atlas_coords = Vector2i(9, 1)
var tile_map_layers = []
var connected_objects = []
var timer: Timer
var mode = PLAN


func init():
	matter_type = Tile.SOLID
	stand.push_back(move_track)
	is_safe = false


func activate_tilemap(tile_map_layer: TileMapLayer) -> void:
	tile_map_layers.push_back(tile_map_layer)
	add_timer(tile_map_layer)


func move_track(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	connected_objects.push_back({
		"object": player,
		"tile_map_layer": tile_map_layer,
		"coords": coords,
		"ms": Time.get_ticks_msec()
	})


func remove_stale_connected_objects() -> void:
	var ms = Time.get_ticks_msec()
	connected_objects = connected_objects.filter(func(co): return ms - co.ms < 50) 
	

func do_plan():
	for tile_map_layer: TileMapLayer in tile_map_layers:
		var coord_list: Array = tile_map_layer.get_used_cells_by_id(0, move_atlas_coords)
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
	
	for tile_map_layer: TileMapLayer in tile_map_layers:
		var coord_list: Array = tile_map_layer.get_used_cells_by_id(0, move_atlas_coords)
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
			if tile_map_layer.get_cell_atlas_coords(coords + dir) != Vector2i(-1, -1):
				continue
			
			# move!
			tile_map_layer.set_cell(coords, -1)
			tile_map_layer.set_cell(coords + dir, 0, move_atlas_coords)

			# remove any lingering bounce effects
			var effect_name = str(coords.x) + "-" + str(coords.y) + "-bump"
			if tile_map_layer.has_node(effect_name):
				tile_map_layer.get_node(effect_name).queue_free()
			
			# move connected objects
			for co in connected_objects:
				if co.tile_map_layer == tile_map_layer && co.coords == coords:
					co.object.position += Vector2(dir * Settings.tile_size)
					break


func add_timer(tile_map_layer: TileMapLayer) -> void:
	if timer:
		return
	timer = Timer.new()
	tile_map_layer.add_child(timer)
	timer.wait_time = 0.5
	timer.connect("timeout", _on_timeout)
	timer.start()


func _on_timeout():
	if mode == PLAN:
		do_plan()
		mode = MOVE
	elif mode == MOVE:
		do_move()
		mode = PLAN


func clear():
	tile_map_layers = []
	connected_objects = []
	if timer:
		timer.queue_free()
		timer = null
	mode = PLAN
