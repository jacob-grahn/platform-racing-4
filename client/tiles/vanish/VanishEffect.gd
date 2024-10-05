extends Node2D

@onready var sprite = $Sprite
@onready var area = $Area
@onready var anim_player = $AnimationPlayer
@onready var anim = $AnimationPlayer.get_animation("vanish")

var _tile_map: TileMap
var _coords: Vector2i
var _atlas_coords: Vector2i
var _vanish: Vanish

var _anim_fading_time = float(0.3)   #Default 0.3
var _anim_gone_time = float(1.995)   #Default 1.995
var _anim_unfading_time = float(0.3) #Default 0.3

var _anim_fading_end_time = float(_anim_fading_time + _anim_gone_time)
var _anim_unfading_end_time = float(_anim_fading_end_time + _anim_unfading_time)

func init(vanish: Vanish, atlas: Texture, atlas_coords: Vector2i, tile_map: TileMap, coords: Vector2i):
	_tile_map = tile_map
	_coords = coords
	_atlas_coords = atlas_coords
	_vanish = vanish
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i((atlas_coords * Settings.tile_size), Settings.tile_size)
	
	var depth = Helpers.get_depth(tile_map)
	var layer = Helpers.to_bitmask_32(depth * 2)
	area.collision_layer = layer
	area.collision_mask = layer
	
	anim.length = _anim_unfading_end_time #Total length
	#Insert Keys into Sprite modulate Track
	anim.track_insert_key(0,float(0),Color(1, 1, 1, 1),1) #Start Disappear
	anim.track_insert_key(0,_anim_fading_time,Color(1, 1, 1, 0), 1) #End Disappear
	anim.track_insert_key(0,_anim_fading_end_time,Color(1, 1, 1, 0),1) #Start Reappear
	anim.track_insert_key(0,_anim_unfading_end_time,Color(1, 1, 1, 1),1) #End Reappear
	#Insert Keys into Node Call Functions Track
	anim.track_insert_key(1,_anim_fading_end_time - 0.1,{"method" : "_avoid_clobber", "args" : []})
	anim.track_insert_key(1,_anim_fading_time,{"method" : "_on_disappear", "args" : []})
	anim.track_insert_key(1,_anim_fading_end_time,{"method" : "_on_reappear", "args" : []})
	anim.track_insert_key(1,_anim_unfading_end_time,{"method" : "_on_anim_complete", "args" : []})

func _attempt_despawn_early():
	var animation_player_time = anim_player.get_current_animation_position()
	if animation_player_time > _anim_fading_time + _anim_gone_time:
		var time_into_unfade = _anim_fading_time + _anim_gone_time + _anim_unfading_time - animation_player_time
		var fade_unfade_ratio = 0
		if _anim_fading_time != 0:
			fade_unfade_ratio = _anim_fading_time / _anim_unfading_time
			anim_player.seek(max(0, time_into_unfade * fade_unfade_ratio))

func _avoid_clobber():
	if area.has_overlapping_bodies():
		var reset_to_time = anim.track_get_key_time(0,3) - anim.track_get_key_time(0,2)
		anim_player.seek(reset_to_time)

func _on_disappear():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,4)
	
func _on_reappear():
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,1)

func _on_anim_complete():
	await get_tree().physics_frame
	if _vanish != null:
		_vanish.remove_from_vanish_dict(_coords)
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,0)
	queue_free()
