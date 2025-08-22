extends Tile
class_name Change

var ChangeController = preload("res://tiles/change/change_controller.gd")

var atlas_coords = Vector2i(3, 31)
var change_frequency: float
var pr3_compatibility = true

func init():
	matter_type = Tile.CHANGE
	change_frequency = default_change_frequency
	# is_safe = false

func activate_tile_map_layer(tile_map_layer: TileMapLayer):
	var change_coord_list = tile_map_layer.get_used_cells_by_id(0, atlas_coords)
	var holder = tile_map_layer.get_parent()
	var spawn = holder.get_node("NonStaticTileMapLayers")
	var change_counter: int = 0
	
	for change_coords in change_coord_list:
		# Erase change blocks from main tile map
		tile_map_layer.set_cell(change_coords, -1)
		
		# Create change controller
		change_counter += 1
		var change_controller = ChangeController.new()
		change_controller.position = Vector2(change_coords * Settings.tile_size)
		change_controller.rotation = tile_map_layer.rotation
		if pr3_compatibility:
			change_controller.change_list = default_change_list.slice(0, 21)
		else:
			change_controller.change_list = default_change_list
		change_controller.change_frequency = change_frequency
		change_controller.name = "ChangeTile" + str(change_counter)
		if spawn:
			spawn.add_child(change_controller)
		else:
			holder.add_child(change_controller)
		# spawn.move_child(change_controller, 4)
		
		# Create sub tile_map_layer
		var sub_tile_map_layer = TileMapLayer.new()
		sub_tile_map_layer.tile_set = tile_map_layer.tile_set
		sub_tile_map_layer.name = "change_block_" + str(change_coords) + "_tile_map_layer"
		sub_tile_map_layer.set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))
		# sub_tile_map.position = -Settings.tile_size_half # doesn't work, workaround in RotationController
		# sub_tile_map.use_kinematic_bodies = true
		change_controller.original_tile_map_layer = tile_map_layer
		change_controller.add_child(sub_tile_map_layer)
