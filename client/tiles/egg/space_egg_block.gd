extends EggBlock
class_name SpaceEggBlock


func init():
	matter_type = Tile.INACTIVE
	egg_atlas_coords = Vector2i(0, 23)
	is_safe = false
	egg_counter = 0
