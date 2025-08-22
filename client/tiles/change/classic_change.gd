extends Change
class_name ClassicChange


func init():
	matter_type = Tile.CHANGE
	atlas_coords = Vector2i(3, 1)
	change_frequency = default_change_frequency
	is_safe = false
