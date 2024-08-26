extends ItemDispenser
class_name ItemDispenserInfinite


func dispense_item(player: Node2D, tile_map: TileMap, coords: Vector2i):
	var item = RANDOM_BLOCK_ITEM.instantiate()
	player.set_item(item)
