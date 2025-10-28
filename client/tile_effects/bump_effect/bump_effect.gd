extends Node2D

@onready var node = $Node
@onready var sprite = $Node/Sprite

var _coords: Vector2i
var _atlas_coords: Vector2i


func set_tile(tile_map_layer: TileMapLayer, coords: Vector2i, rotation_rad: float) -> void:
	var atlas_coords = tile_map_layer.get_cell_atlas_coords(coords)
	var source: TileSetAtlasSource = tile_map_layer.tile_set.get_source(0)
	var tile_data: TileData = tile_map_layer.get_cell_tile_data(coords)
	var atlas = source.texture
	
	sprite.modulate = tile_data.modulate
	sprite.rotation = rotation_rad
	sprite.texture = atlas
	sprite.region_rect = Rect2i(atlas_coords * Settings.tile_size, Settings.tile_size)
	
	_coords = coords
	_atlas_coords = atlas_coords


func finish():
	var tile_map_layer: TileMapLayer = get_parent()
	var atlas_coords: Vector2i = tile_map_layer.get_cell_atlas_coords(_coords)
	var alt_id: int = tile_map_layer.get_cell_alternative_tile(_coords)
	await get_tree().physics_frame
	if _atlas_coords == atlas_coords:
		if alt_id == Tile.INVISIBLE_DEACTIVATED_ALT_ID:
			tile_map_layer.set_cell(_coords, 0, _atlas_coords, Tile.DEACTIVATED_ALT_ID)
		else:
			tile_map_layer.set_cell(_coords, 0, _atlas_coords, Tile.VISIBLE_ALT_ID)
	queue_free()
