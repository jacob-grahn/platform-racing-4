extends Start
class_name SpaceStart


func init():
	matter_type = Tile.START
	start_atlas_coords = Vector2i(1, 21)
	Start.i = 0
