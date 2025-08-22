extends PresenceSwitch
class_name DesertPresenceSwitch


func init():
	gear_atlas_coords = Vector2i(4, 8)
	matter_type = Tile.INACTIVE
	area.push_back(presence_switch)
