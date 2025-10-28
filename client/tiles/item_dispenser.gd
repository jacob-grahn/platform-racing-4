extends Tile
class_name ItemDispenser

var item_id: int = 0


func init():
	matter_type = Tile.SOLID
	bump.push_back(dispense_item)


func dispense_item(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	if !is_active(tile_map_layer, coords):
		return
	
	# grant an item
	item_id = randi_range(1, 14)
	player.set_item(item_id)
	
	# deactivate this tile
	deactivate(tile_map_layer, coords)
