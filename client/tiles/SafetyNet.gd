extends Tile
class_name SafetyNet


func init():
	matter_type = Tile.GAS
	area.push_back(safety_net)


func safety_net(player: Node2D, tilemap: TileMap, coords: Vector2i):
	player.position.x = player.last_safe_position.x
	player.position.y = player.last_safe_position.y
