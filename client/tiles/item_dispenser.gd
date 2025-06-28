extends Tile
class_name ItemDispenser

var item_id: int = 0


func init():
	matter_type = Tile.SOLID
	bump.push_back(dispense_item)


func dispense_item(player: Node2D, tile_map: TileMapLayer, coords: Vector2i):
	if !is_active(tile_map, coords):
		return
	
	# grant an item
	item_id = randi_range(1, 14)
	player.set_item(item_id)
	
	# deactivate this tile
	deactivate(tile_map, coords)
