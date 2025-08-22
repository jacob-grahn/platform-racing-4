extends Tile
class_name Move

const PLAN: String = "plan"
const MOVING: String = "move"

var MoveArrowEffect: PackedScene = preload("res://tile_effects/move_arrow_effect/move_arrow_effect.tscn")
var move_atlas_coords = Vector2i(9, 31)
var tile_map_layers = []
var connected_objects = []
var move_direction_list = []
var move_list_pointer: int
var timer: Timer
var time: float
var mode = PLAN


func init():
	matter_type = Tile.MOVE
	# stand.push_back(move_track)
	is_safe = false


func activate_tile_map_layer(tile_map_layer: TileMapLayer) -> void:
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
	move_direction_list.clear()
	move_list_pointer = -1
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
			move_direction_list.append(dir)
			var effect_name = str(coords.x) + "-" + str(coords.y) + "-move-arrow"
			var effect_node = tile_map_layer.get_parent().get_node("Effects")
			if effect_node.has_node(effect_name):
				return
			var effect = MoveArrowEffect.instantiate()
			effect.position = (coords * Settings.tile_size) + Settings.tile_size_half
			effect.name = effect_name
			effect.arrowdir = rand
			effect_node.add_child(effect)


func do_move():
	move_list_pointer = -1
	remove_stale_connected_objects()
	
	for tile_map_layer: TileMapLayer in tile_map_layers:
		var coord_list: Array = tile_map_layer.get_used_cells_by_id(0, move_atlas_coords)
		for coords: Vector2i in coord_list:
			move_list_pointer += 1
			var dir = move_direction_list[move_list_pointer]
			
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
	move_direction_list.clear()


func add_timer(tile_map_layer: TileMapLayer) -> void:
	if timer:
		return
	timer = Timer.new()
	tile_map_layer.add_child(timer)
	timer.wait_time = 1.25
	timer.connect("timeout", _on_timeout)
	timer.start()


func _on_timeout():
	if mode == PLAN:
		do_plan()
		mode = MOVING
	elif mode == MOVING:
		do_move()
		mode = PLAN


func clear():
	tile_map_layers = []
	connected_objects = []
	if timer:
		timer.queue_free()
		timer = null
	mode = PLAN
