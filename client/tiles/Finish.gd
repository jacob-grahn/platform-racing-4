extends Tile
class_name Finish


func init():
	matter_type = Tile.SOLID
	is_safe = true
	bump.push_back(finish)


func finish(player: Node2D, tilemap: TileMap, coords: Vector2i):
	player.get_parent().get_parent().get_parent().get_parent().finish() # todo: this is not hacky at all
