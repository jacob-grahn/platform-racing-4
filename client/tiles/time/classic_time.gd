extends TimeBlock
class_name ClassicTimeBlock


func init():
	matter_type = Tile.ACTIVE
	bump.push_back(inc_time)
