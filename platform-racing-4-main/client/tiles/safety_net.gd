extends Tile
class_name SafetyNet


func init():
	matter_type = Tile.GAS
	area.push_back(safety_net)


func safety_net(player: Node2D, tilemap: TileMap, coords: Vector2i):
	player.position.x = player.tile_interaction.last_safe_position.x
	player.position.y = player.tile_interaction.last_safe_position.y
	player.velocity = Vector2(0, 0)

	if (player.tile_interaction.last_safe_layer != null and (player.tile_interaction.last_safe_layer.get_node("Players") != player.get_parent())):
		player.get_parent().remove_child(player)
		player.tile_interaction.last_safe_layer.get_node("Players").add_child(player)
		player.set_depth(player.tile_interaction.last_safe_layer.depth)
