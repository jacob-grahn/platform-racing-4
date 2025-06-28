extends Tile
class_name Gear

var RotationController = preload("res://tiles/gear/rotation_controller.gd")

func init():
	is_safe = false

func activate_tilemap(tile_map: TileMapLayer):
	var gear_coord_list = tile_map.get_used_cells_by_id(0, Vector2i(4, 3))
	var switch_atlas_coords = Vector2i(5, 3)
	var holder = tile_map.get_parent()
	
	for gear_coords in gear_coord_list:
		# Erase gears from main tile map
		tile_map.set_cell(gear_coords, -1)
	
		# Create rotation controller
		var rotation_controller = RotationController.new()
		rotation_controller.position = Vector2(gear_coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
		rotation_controller.rotation = tile_map.rotation
		rotation_controller.target_rotation = tile_map.rotation
		holder.add_child(rotation_controller)
		holder.move_child(rotation_controller, 4)
		
		# Create sub tilemap
		var sub_tile_map = TileMapLayer.new()
		sub_tile_map.tile_set = tile_map.tile_set
		sub_tile_map.name = "gear_" + str(gear_coords) + "_tilemap"
		sub_tile_map.set_cell(Vector2i(0, 0), 0, Vector2i(4, 3))
		sub_tile_map.position = -Settings.tile_size_half # doesn't work, workaround in RotationController
		sub_tile_map.use_kinematic_bodies = true
		rotation_controller.add_child(sub_tile_map)
		
		# Transfer tiles connected to the gear into the sub tilemap
		var queue = [gear_coords + Vector2i(0, 1)]
		while(len(queue) > 0):
			var coords: Vector2i = queue.pop_back()
			var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(coords)
			if atlas_coords.x != -1:
				tile_map.set_cell(coords, -1)
				sub_tile_map.set_cell(coords - gear_coords, 0, atlas_coords)
				queue.append_array(tile_map.get_surrounding_cells(coords))
				
				# If there is a switch, deactivate rotation by default
				if atlas_coords == switch_atlas_coords:
					rotation_controller.enabled = false
					rotation_controller.tick_ms = 2000
