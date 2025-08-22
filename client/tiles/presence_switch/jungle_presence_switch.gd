extends PresenceSwitch
class_name JunglePresenceSwitch


func init():
	gear_atlas_coords = Vector2i(4, 18)
	matter_type = Tile.INACTIVE
	area.push_back(presence_switch)
