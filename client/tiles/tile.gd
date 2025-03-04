class_name Tile

const STATIC = 'static'

const SOLID = 'solid'
const LIQUID = 'liquid'
const GAS = 'gas'

const VISIBLE_ALT_ID = 0
const INVISIBLE_ALT_ID = 1
const DEACTIVATED_ALT_ID = 2
const INVISIBLE_DEACTIVATED_ALT_ID = 3

var top = []
var left = []
var right = []
var bottom = []
var any_side = [] # includes top, left, right, and bottom
var stand = [] # could be any side depending on player rotation
var bump = [] # could be any side depending on player rotation
var tick = [] # will run on some interval
var area = [] # used for tiles with no collision like water
var physics_type = STATIC
var matter_type = SOLID
var is_safe: bool = true
var cooldown_dict = {}


func init():
	pass


func clear():
	pass


func on(event: String, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	for behavior in self[event]:
		behavior.call(source, target, coords)


func activate_tilemap(tile_map: TileMap) -> void:
	pass


func get_center_position(tile_map: TileMap, coords: Vector2i) -> Vector2:
	return (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map.rotation)


func deactivate(tile_map: TileMap, coords: Vector2i):
	var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(0, coords)
	tile_map.set_cell(0, coords, 0, atlas_coords, Tile.DEACTIVATED_ALT_ID)


func set_visible(tile_map: TileMap, coords: Vector2i, visible: bool):
	var atlas_coords: Vector2i = tile_map.get_cell_atlas_coords(0, coords)
	var alt_id
	if visible:
		if is_active(tile_map, coords):
			alt_id = Tile.VISIBLE_ALT_ID
		else:
			alt_id = Tile.DEACTIVATED_ALT_ID
	else:
		if is_active(tile_map, coords):
			alt_id = Tile.INVISIBLE_ALT_ID
		else:
			alt_id = Tile.INVISIBLE_DEACTIVATED_ALT_ID
	tile_map.set_cell(0, coords, 0, atlas_coords, alt_id)


func is_active(tile_map: TileMap, coords: Vector2i) -> bool:
	var alt_id = tile_map.get_cell_alternative_tile(0, coords)
	return alt_id == Tile.VISIBLE_ALT_ID || alt_id == Tile.INVISIBLE_ALT_ID


func is_visible(tile_map: TileMap, coords: Vector2i) -> bool:
	var alt_id = tile_map.get_cell_alternative_tile(0, coords)
	return alt_id == Tile.DEACTIVATED_ALT_ID || alt_id == Tile.VISIBLE_ALT_ID


func get_slug(tile_map: TileMap, coords: Vector2i) -> String:
	return str(tile_map.get_path()) + "/" + str(coords)


func cooldown(tile_map: TileMap, coords: Vector2i, seconds: float) -> bool:
	var ms: int = int(seconds * 1000)
	var key: String = get_slug(tile_map, coords)
	var last: int = cooldown_dict.get(key, 0)
	var current: int = Time.get_ticks_msec()
	var elapsed: int = current - last
	var is_cooling_down: bool = elapsed < ms
	if !is_cooling_down:
		cooldown_dict[key] = current
	return is_cooling_down
