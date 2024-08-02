extends Node2D

@onready var timer = $Timer
@onready var tile_atlas = $TileAtlas
var tile_id: int = 0


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
	var atlas_coords: Vector2i = Helpers.to_atlas_coords(tile_id)
	var atlas_position: Vector2i = atlas_coords * Settings.tile_size
	tile_atlas.region_rect = Rect2i(atlas_position, Settings.tile_size)


func use(delta: float) -> bool:
	var tile_map:TileMap = get_node("../../../../TileMap")
	var global_position = to_global(Vector2(0, 0))
	var tilemap_position = tile_map.to_local(global_position)
	var coords: Vector2i = Vector2i(tilemap_position.round()) / Settings.tile_size
	var atlas_coords: Vector2i = Helpers.to_atlas_coords(tile_id)
	tile_map.set_cell(0, coords, 0, atlas_coords)
	return false
