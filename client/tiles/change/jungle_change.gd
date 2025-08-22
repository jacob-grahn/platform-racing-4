extends Change
class_name JungleChange


func init():
	matter_type = Tile.CHANGE
	atlas_coords = Vector2i(3, 16)
	change_frequency = default_change_frequency
	is_safe = false
