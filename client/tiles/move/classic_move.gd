extends Move
class_name ClassicMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 1)
	is_safe = false
