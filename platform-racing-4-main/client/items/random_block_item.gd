extends Node2D
class_name RandomBlockItem

@onready var timer = $Timer
@onready var tile_atlas = $TileAtlas
var tile_id: int = 0
var using: bool = false
var remove: bool = false


func _ready():
	timer.connect("timeout", _on_timeout)
	_set_random_tile_id()


func _on_timeout():
	_set_random_tile_id()


func _set_random_tile_id() -> void:
	var tile_id = randi_range(1, 39)
	_set_tile_id(tile_id)


func _set_tile_id(new_tile_id: int) -> void:
	tile_id = new_tile_id
	var atlas_coords: Vector2i = CoordinateUtils.to_atlas_coords(tile_id)
	var atlas_position: Vector2i = atlas_coords * Settings.tile_size
	tile_atlas.region_rect = Rect2i(atlas_position, Settings.tile_size)


func activate_item():
	using = true
	var tile_map: TileMap = get_node("../../../../../TileMap")
	var global_position = to_global(Vector2(0, 0))
	var tilemap_position = tile_map.to_local(global_position)
	var coords: Vector2i = Vector2i(tilemap_position.round()) / Settings.tile_size
	var atlas_coords: Vector2i = CoordinateUtils.to_atlas_coords(tile_id)
	tile_map.set_cell(0, coords, 0, atlas_coords)
	remove = true
	
func still_have_item():
	if !remove:
		return true
	else:
		return false
