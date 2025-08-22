extends Tile
class_name Sticky


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(stick)
	is_safe = true


func stick(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	player.movement.on_sticky_block = true
