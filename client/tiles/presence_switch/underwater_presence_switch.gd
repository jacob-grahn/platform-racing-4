extends PresenceSwitch
class_name UnderwaterPresenceSwitch


func init():
	gear_atlas_coords = Vector2i(4, 28)
	matter_type = Tile.INACTIVE
	area.push_back(presence_switch)
