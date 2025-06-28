extends Tile
class_name PresenceSwitch


func init():
	matter_type = Tile.GAS
	area.push_back(presence_switch)


func presence_switch(node: Node2D, tilemap: TileMapLayer, _coords: Vector2i)->void:
	var gear_list = tilemap.get_used_cells_by_id(0, Vector2i(4, 3))
	if len(gear_list) > 0:
		var rotation_controller = tilemap.get_parent()
		rotation_controller.enabled_temp = true
