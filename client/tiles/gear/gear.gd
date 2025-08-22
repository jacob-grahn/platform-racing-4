extends Tile
class_name Gear


var RotationController = preload("res://tiles/gear/rotation_controller.gd")
var gear_atlas_coords = Vector2i(4, 33)

func init():
	is_safe = false


func activate_tile_map_layer(tile_map_layer: TileMapLayer):
	var gear_coord_list = tile_map_layer.get_used_cells_by_id(0, gear_atlas_coords)
	var switch_atlas_coords = Vector2i(5, 3)
	var holder = tile_map_layer.get_parent()
	var spawn = holder.get_node("NonStaticTileMapLayers")
	var gear_counter: int = 0
	
	for gear_coords in gear_coord_list:
		# Erase gears from main tile map
		tile_map_layer.set_cell(gear_coords, -1)
	
		# Create rotation controller
		gear_counter += 1
		var rotation_controller = RotationController.new()
		rotation_controller.position = Vector2(gear_coords * Settings.tile_size) + Vector2(Settings.tile_size_half)
		rotation_controller.rotation = tile_map_layer.rotation
		rotation_controller.target_rotation = tile_map_layer.rotation
		rotation_controller.name = "GearTile" + str(gear_counter)
		if spawn:
			spawn.add_child(rotation_controller)
		else:
			holder.add_child(rotation_controller)
		# spawn.move_child(rotation_controller, 4)
		
		# Create sub tile_map_layer
		var sub_tile_map_layer = TileMapLayer.new()
		sub_tile_map_layer.tile_set = tile_map_layer.tile_set
		sub_tile_map_layer.name = "gear_" + str(gear_coords) + "_tile_map_layer"
		sub_tile_map_layer.set_cell(Vector2i(0, 0), 0, Vector2i(4, 3))
		sub_tile_map_layer.position = -Settings.tile_size_half # doesn't work, workaround in RotationController
		sub_tile_map_layer.use_kinematic_bodies = true
		rotation_controller.add_child(sub_tile_map_layer)
		
		# Transfer tiles connected to the gear into the sub tile_map_layer
		var queue = [gear_coords + Vector2i(0, 1)]
		while(len(queue) > 0):
			var coords: Vector2i = queue.pop_back()
			var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
			if atlas_coords.x != -1:
				tile_map_layer.set_cell(coords, -1)
				sub_tile_map_layer.set_cell(coords - gear_coords, 0, atlas_coords)
				queue.append_array(tile_map_layer.get_surrounding_cells(coords))
				
				# If there is a switch, deactivate rotation by default
				if atlas_coords == switch_atlas_coords:
					rotation_controller.enabled = false
					rotation_controller.tick_ms = 2000
