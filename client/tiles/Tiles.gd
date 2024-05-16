class_name Tiles

var map = {}
var RotationController = preload("res://pages/game/RotationController.gd")


func init_defaults() -> void:
	var arrow_down:BehaviorGroup = BehaviorGroup.new()
	arrow_down.any_side.push_back(Behaviors.push_down)
	map['5'] = arrow_down
	
	var arrow_up:BehaviorGroup = BehaviorGroup.new()
	arrow_up.any_side.push_back(Behaviors.push_up)
	map['6'] = arrow_up
	
	var arrow_left:BehaviorGroup = BehaviorGroup.new()
	arrow_left.any_side.push_back(Behaviors.push_left)
	map['7'] = arrow_left
	
	var arrow_right:BehaviorGroup = BehaviorGroup.new()
	arrow_right.any_side.push_back(Behaviors.push_right)
	map['8'] = arrow_right
	
	var area_switch:BehaviorGroup = BehaviorGroup.new()
	area_switch.area.push_back(Behaviors.ares_switch)
	map['35'] = area_switch


func on(event: String, tile_type: int, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var behavior_group:BehaviorGroup = map[str(tile_type)]
		behavior_group.on(event, source, target, coords)


func activate(game):
	var tile_map = game.get_node("TileMap")
	var gear_coord_list = tile_map.get_used_cells_by_id(0, 0, Vector2i(4, 3))
	var switch_atlas_coords = Vector2i(5, 3)
	
	for gear_coords in gear_coord_list:
		# Erase gears from main tile map
		tile_map.set_cell(-1, gear_coords)
	
		# Create rotation controller
		var rotation_controller = RotationController.new()
		rotation_controller.position = Vector2(gear_coords * 128) + Vector2(64, 64)
		game.add_child(rotation_controller)
		game.move_child(rotation_controller, 0)
		
		# Create sub tilemap
		var sub_tile_map = TileMap.new()
		sub_tile_map.tile_set = tile_map.tile_set
		sub_tile_map.set_cell(0, Vector2i(0, 0), 0, Vector2i(4, 3))
		sub_tile_map.position = Vector2(-64, -64)
		rotation_controller.add_child(sub_tile_map)
		
		# Transfer tiles connected to the gear into the sub tilemap
		var queue = [gear_coords + Vector2i(0, 1)]
		while(len(queue) > 0):
			var coords: Vector2i = queue.pop_back()
			var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(0, coords)
			if atlas_coords.x != -1:
				tile_map.set_cell(-1, coords)
				sub_tile_map.set_cell(0, coords - gear_coords, 0, atlas_coords)
				queue.append_array(tile_map.get_surrounding_cells(coords))
				
				# If there is a switch, deactivate rotation by default
				if atlas_coords == switch_atlas_coords:
					rotation_controller.enabled = false
					rotation_controller.tick_ms = 2000
				
