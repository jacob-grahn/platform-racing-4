class_name Finish
extends Tile
## Finish tile that ends the level when a player touches it
##
## When a player reaches this tile, the level is completed
## and the game transitions to the finish state.


func init() -> void:
	matter_type = Tile.ACTIVE
	is_safe = true
	bump.push_back(finish)


func finish(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	if !player.movement.finished:
		player.movement.finished = true
		Jukebox.play_sound("victory")
