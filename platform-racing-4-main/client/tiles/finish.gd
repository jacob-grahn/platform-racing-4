class_name Finish
extends Tile
## Finish tile that ends the level when a player touches it
##
## When a player reaches this tile, the level is completed
## and the game transitions to the finish state.


func init() -> void:
	matter_type = Tile.SOLID
	is_safe = true
	bump.push_back(finish)


func finish(player: Node2D, tilemap: TileMap, coords: Vector2i) -> void:
	# todo: this is not hacky at all
	player.get_parent().get_parent().get_parent().get_parent().finish()
