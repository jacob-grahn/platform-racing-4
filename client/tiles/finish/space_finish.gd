extends Finish
class_name SpaceFinish
## Finish tile that ends the level when a player touches it
##
## When a player reaches this tile, the level is completed
## and the game transitions to the finish state.


func init() -> void:
	matter_type = Tile.ACTIVE
	is_safe = true
	bump.push_back(finish)
