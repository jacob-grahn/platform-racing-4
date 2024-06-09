extends Tile
class_name Start

static var start_coords = []
static var i = 0


func init():
	matter_type = Tile.GAS
	Start.i = 0


func activate_tilemap(tilemap: TileMap) -> void:
	start_coords = tilemap.get_used_cells_by_id(0, 0, Vector2i(1, 1))


static func get_next_start_coords() -> Vector2i:
	if len(start_coords) > 0:
		var coords = start_coords[i]
		i += 1
		if i >= len(start_coords):
			i = 0
		return coords
	else:
		return Vector2i(0, 0)
