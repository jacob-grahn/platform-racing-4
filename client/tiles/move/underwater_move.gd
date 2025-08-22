extends Move
class_name UnderwaterMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 26)
	is_safe = false
