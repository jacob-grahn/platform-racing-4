extends EggBlock
class_name UnderwaterEggBlock


func init():
	matter_type = Tile.INACTIVE
	egg_atlas_coords = Vector2i(0, 28)
	is_safe = false
	egg_counter = 0
