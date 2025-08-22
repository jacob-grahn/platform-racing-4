extends PresenceSwitch
class_name ClassicPresenceSwitch


func init():
	gear_atlas_coords = Vector2i(4, 3)
	matter_type = Tile.INACTIVE
	area.push_back(presence_switch)
