extends Move
class_name JungleMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 16)
	is_safe = false
