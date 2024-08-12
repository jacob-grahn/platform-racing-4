extends ItemDispenser
class_name ItemDispenserInfinite


func init():
	super.init()
	item_atlas_coords = Vector2i(5, 2)


func deactivate(tile_map: TileMap, coords: Vector2i):
	pass
