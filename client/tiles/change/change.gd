extends Tile
class_name Change

var ChangeController = preload("res://tiles/change/change_controller.gd")

var default_change_list: Array = [1, 5, 18, 27, 16, 26, 11, 10, 23, 22, 28, 25, 19, 21, 33, 32, 34, 13, 7, 6, 8, 9, 29, 30, 37, 38, 39]
var timer: float = 0
var pr3_compatibility = true

func init():
	# is_safe = false
	pass

func activate_tile_map_layer(tile_map_layer: TileMapLayer):
	var change_coord_list = tile_map_layer.get_used_cells_by_id(0, Vector2i(3, 1))
	var holder = tile_map_layer.get_parent()
	
	for change_coords in change_coord_list:
		# Erase change blocks from main tile map
		tile_map_layer.set_cell(change_coords, -1)
		
		# Create change controller
		var change_controller = ChangeController.new()
		change_controller.position = Vector2(change_coords * Settings.tile_size)
		change_controller.rotation = tile_map_layer.rotation
		holder.add_child(change_controller)
		holder.move_child(change_controller, 4)
		
		# Create sub tile_map_layer
		var sub_tile_map_layer = TileMapLayer.new()
		sub_tile_map_layer.tile_set = tile_map_layer.tile_set
		sub_tile_map_layer.name = "change_block_" + str(change_coords) + "_tile_map_layer"
		sub_tile_map_layer.set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))
		# sub_tile_map.position = -Settings.tile_size_half # doesn't work, workaround in RotationController
		# sub_tile_map.use_kinematic_bodies = true
		change_controller.add_child(sub_tile_map_layer)
