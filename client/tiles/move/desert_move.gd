extends Move
class_name DesertMove


func init():
	matter_type = Tile.MOVE
	move_atlas_coords = Vector2i(9, 6)
	is_safe = false
