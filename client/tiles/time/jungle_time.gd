extends TimeBlock
class_name JungleTimeBlock


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(inc_time)
