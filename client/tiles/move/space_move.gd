extends Move
class_name SpaceMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 21)
	is_safe = false
