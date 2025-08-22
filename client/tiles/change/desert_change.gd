extends Change
class_name DesertChange


func init():
	matter_type = Tile.CHANGE
	atlas_coords = Vector2i(3, 6)
	change_frequency = default_change_frequency
	is_safe = false
