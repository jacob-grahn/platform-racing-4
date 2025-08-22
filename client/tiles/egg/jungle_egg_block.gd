extends EggBlock
class_name JungleEggBlock


func init():
	matter_type = Tile.INACTIVE
	egg_atlas_coords = Vector2i(0, 18)
	is_safe = false
	egg_counter = 0
