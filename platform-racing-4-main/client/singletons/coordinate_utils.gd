extends Node
## Provides utility functions for coordinate conversions.

func to_atlas_coords(block_id: int) -> Vector2i:
	if block_id == 0:
		return Vector2i(-1, -1)
	var id := block_id - 1
	var x := id % 10
	var y := id / 10
	return Vector2i(x, y)


func to_block_id(atlas_coords: Vector2i) -> int:
	return (atlas_coords.y * 10) + atlas_coords.x + 1
