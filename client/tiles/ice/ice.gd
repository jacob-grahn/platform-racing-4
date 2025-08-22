extends Tile
class_name Ice


func init():
	matter_type = Tile.ACTIVE
	any_side.push_back(freeze)
	is_safe = true


func freeze(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	player.movement.on_ice = true
