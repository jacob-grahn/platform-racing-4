extends ItemDispenser
class_name SpaceItemDispenserInfinite


func dispense_item(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	item_id = randi_range(1, 14)
	player.set_item(item_id)
