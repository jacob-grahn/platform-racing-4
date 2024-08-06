extends Node2D

#@onready var static_body = $StaticBody
@onready var sprite = $Sprite
@onready var area = $Area
@onready var animation_player = $AnimationPlayer
var _tile_map: TileMap
var _coords: Vector2i
var _atlas_coords: Vector2i
var _appear: Appear


func init(appear: Appear, atlas: Texture, atlas_coords: Vector2i, tile_map: TileMap, coords: Vector2i):
	_tile_map = tile_map
	_coords = coords
	_atlas_coords = atlas_coords
	_appear = appear
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i((atlas_coords * Settings.tile_size), Settings.tile_size)
	
	var depth = Helpers.get_depth(tile_map)
	var layer = Helpers.to_bitmask_32(depth * 2)
	area.collision_layer = layer
	area.collision_mask = layer

func reinit():
	reappear_check()
					
func reappear_check():
	if animation_player.current_animation_position >= 1:
			animation_player.seek(sprite.modulate.a)

func _on_anim_complete():
	if _appear != null:
		_appear.remove_from_appear_dict(_coords)
	queue_free()