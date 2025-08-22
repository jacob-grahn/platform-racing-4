extends Sad
class_name JungleSad


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(sad)
	is_safe = true
