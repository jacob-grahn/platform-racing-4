extends Node2D

@onready var static_body = $StaticBody
@onready var sprite = $Sprite
@onready var area = $Area
@onready var animation_player = $AnimationPlayer
var _tile_map: TileMap
var _coords: Vector2i
var _atlas_coords: Vector2i


func init(atlas: Texture, atlas_coords: Vector2i, tile_map: TileMap, coords: Vector2i):
	_tile_map = tile_map
	_coords = coords
	_atlas_coords = atlas_coords
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i((atlas_coords * Settings.tile_size), Settings.tile_size)
	
	var depth = round(tile_map.get_parent().follow_viewport_scale * 10)
	var layer = Helpers.to_bitmask_32(depth * 2)
	static_body.collision_layer = layer 
	static_body.collision_mask = layer
	area.collision_layer = layer
	area.collision_mask = layer


func _avoid_clobber():
	if area.has_overlapping_bodies():
		animation_player.seek(2.0)


func _on_anim_complete():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords)
	queue_free()
