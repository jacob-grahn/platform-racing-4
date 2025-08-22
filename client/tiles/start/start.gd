extends Tile
class_name Start

static var start_options = []
static var i = 0
var start_atlas_coords = Vector2i(1, 31)


func init():
	matter_type = Tile.START
	Start.i = 0


func activate_tile_map_layer(tile_map_layer: TileMapLayer) -> void:
	var coord_list = tile_map_layer.get_used_cells_by_id(0, start_atlas_coords)
	for coords in coord_list:
		var start_option = {
			"layer_name": str(tile_map_layer.get_parent().name),
			"coords": coords,
			"tile_map_layer": tile_map_layer,
		}
		start_options.push_back(start_option)


func clear():
	start_options = []


static func get_next_start_option(layers: Node2D) -> Dictionary:
	if len(start_options) > 0:
		var start_option = start_options[i]
		i += 1
		if i >= len(start_options):
			i = 0
		return start_option
	else:
		return {
			"layer_name": layers.get_target_layer(),
			"coords": Vector2i(0, 0),
			"tile_map_layer": null,
		}
