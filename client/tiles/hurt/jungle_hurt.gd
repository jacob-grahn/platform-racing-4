extends Hurt
class_name JungleHurt


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(hurt)
	is_safe = false
