extends Tile
class_name ItemDispenser

const RANDOM_BLOCK_ITEM = preload("res://items/RandomBlockItem.tscn")


func init():
	matter_type = Tile.SOLID
	bump.push_back(dispense_item)


func dispense_item(player: Node2D, tile_map: TileMap, coords: Vector2i):
	if !is_active(tile_map, coords):
		return
	
	# grant an item
	var item = RANDOM_BLOCK_ITEM.instantiate()
	player.set_item(item)
	
	# deactivate this tile
	deactivate(tile_map, coords)
