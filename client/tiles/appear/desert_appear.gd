extends Appear
class_name DesertAppear

func init():
	matter_type = Tile.ACTIVE
	atlas_coords = Vector2i(9, 8)
	any_side.push_back(appear)
