extends EggBlock
class_name ClassicEggBlock


func init():
	matter_type = Tile.INACTIVE
	egg_atlas_coords = Vector2i(0, 3)
	is_safe = false
	egg_counter = 0
