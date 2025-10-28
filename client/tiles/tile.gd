class_name Tile
## Base class for all tiles with behavior and collision handling
##
## Provides the foundation for all game tiles, including collision detection,
## behavior callbacks, and state management (active/inactive, visible/invisible).

const STATIC := "static"

const SOLID := "solid"
const LIQUID := "liquid"
const GAS := "gas"

const ACTIVE := "active"
const CHANGE := "change"
const IMPERVIOUS := "impervious"
const INACTIVE := "inactive"
const MOVE := "move"
const START := "start"
const WATER := "water"

const VISIBLE_ALT_ID := 0
const INVISIBLE_ALT_ID := 1
const DEACTIVATED_ALT_ID := 2
const INVISIBLE_DEACTIVATED_ALT_ID := 3

var top := []
var left := []
var right := []
var bottom := []
var any_side := [] # includes top, left, right, and bottom
var stand := [] # could be any side depending on player rotation
var bump := [] # could be any side depending on player rotation
var tick := [] # will run on some interval
var area := [] # used for tiles with no collision like water
var options_menu = null
var physics_type := STATIC
var matter_type := ACTIVE
var block_side_settings := {"type": ACTIVE, "top": [], "bottom": [], "left": [], "right": [], "bump": [],}
var is_safe: bool = true
var cooldown_dict := {}
var default_change_list: Array = [1, 5, 18, 27, 16, 26, 11, 10, 23, 22, 28, 25, 19, 21, 33, 32, 34, 13, 7, 6, 8, 9, 29, 30, 37, 38, 39]
var default_change_frequency: float = 2.5
var default_move_frequency: float = 2.5
var default_custom_stats: Array = [50, 50, 50, 50]


func init() -> void:
	pass


func clear() -> void:
	pass


func on(event: String, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	for behavior in self[event]:
		behavior.call(source, target, coords)


func activate_tile_map_layer(tile_map_layer: TileMapLayer) -> void:
	pass


func get_center_position(tile_map_layer: TileMapLayer, coords: Vector2i) -> Vector2:
	return (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map_layer.rotation)


func deactivate(tile_map_layer: TileMapLayer, coords: Vector2i) -> void:
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	tile_map_layer.set_cell(coords, 0, atlas_coords, Tile.DEACTIVATED_ALT_ID)


func set_visible(tile_map_layer: TileMapLayer, coords: Vector2i, visible: bool) -> void:
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(coords)
	var alt_id: int
	if visible:
		if is_active(tile_map_layer, coords):
			alt_id = Tile.VISIBLE_ALT_ID
		else:
			alt_id = Tile.DEACTIVATED_ALT_ID
	else:
		if is_active(tile_map_layer, coords):
			alt_id = Tile.INVISIBLE_ALT_ID
		else:
			alt_id = Tile.INVISIBLE_DEACTIVATED_ALT_ID
	tile_map_layer.set_cell(coords, 0, atlas_coords, alt_id)


func is_active(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == Tile.VISIBLE_ALT_ID or alt_id == Tile.INVISIBLE_ALT_ID


func is_visible(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var alt_id := tile_map_layer.get_cell_alternative_tile(coords)
	return alt_id == Tile.DEACTIVATED_ALT_ID or alt_id == Tile.VISIBLE_ALT_ID


func has_options_menu(tile_map_layer: TileMapLayer, coords: Vector2i) -> bool:
	var tile = tile_map_layer.get_cell_tile_data(coords)
	return tile.options_menu != null


func get_slug(tile_map_layer: TileMapLayer, coords: Vector2i) -> String:
	return str(tile_map_layer.get_path()) + "/" + str(coords)


func cooldown(tile_map_layer: TileMapLayer, coords: Vector2i, seconds: float) -> bool:
	var ms: int = int(seconds * 1000)
	var key: String = get_slug(tile_map_layer, coords)
	var last: int = cooldown_dict.get(key, 0)
	var current: int = Time.get_ticks_msec()
	var elapsed: int = current - last
	var is_cooling_down: bool = elapsed < ms
	if not is_cooling_down:
		cooldown_dict[key] = current
	return is_cooling_down
