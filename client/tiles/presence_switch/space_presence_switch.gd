extends PresenceSwitch
class_name SpacePresenceSwitch


func init():
	gear_atlas_coords = Vector2i(4, 23)
	matter_type = Tile.INACTIVE
	area.push_back(presence_switch)
