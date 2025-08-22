extends Node
## Provides utility functions for coordinate conversions.

var tiles: Tiles = Tiles.new() # references stuff from tiles script
var rows: int = tiles.rows
var columns: int = tiles.columns
var total_blocks_in_atlas_coords: int = tiles.total_blocks_in_atlas_coords
var seperator: int = tiles.blocks_for_each_category


func to_atlas_coords(block_id: int) -> Vector2i:
	if block_id == 0:
		return Vector2i(-1, -1)
	var true_block_id: int = block_id
	var style_counter: int = 0
	while true_block_id > seperator:
		true_block_id -= seperator
		style_counter += 1
	var id := (true_block_id + (total_blocks_in_atlas_coords * style_counter)) - 1
	var x := id % rows
	var y := id / rows
	return Vector2i(x, y)


func to_block_id(atlas_coords: Vector2i) -> int:
	var block_id = (atlas_coords.y * rows) + atlas_coords.x + 1
	var style_counter: int = 0
	while block_id > total_blocks_in_atlas_coords:
		block_id -= total_blocks_in_atlas_coords
		style_counter += 1
	var true_block_id = (block_id + (seperator * style_counter))
	return int(true_block_id)
