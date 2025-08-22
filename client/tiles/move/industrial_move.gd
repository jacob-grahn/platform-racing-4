extends Move
class_name IndustrialMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 11)
	is_safe = false
