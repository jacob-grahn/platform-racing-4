extends Node2D

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
	
	var depth = Helpers.get_depth(tile_map)
	var layer = Helpers.to_bitmask_32(depth * 2)
	area.collision_layer = layer
	area.collision_mask = layer

func _avoid_clobber():
	if area.has_overlapping_bodies():
		var _anim = animation_player.get_animation("vanish")
		var reset_to_time = _anim.track_get_key_time(0,3) - 0.75 * _anim.track_get_key_time(0,2) #Set to where 0.75 of gone_time remains
		animation_player.seek(reset_to_time)

func _on_disappear():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,4)
	
func _on_reappear():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,1)

func _on_anim_complete():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,0)
	queue_free()
