extends Node2D

#@onready var static_body = $StaticBody
@onready var sprite = $Sprite
@onready var area = $Area
@onready var animation_player = $AnimationPlayer
var _tile_map: TileMapLayer
var _coords: Vector2i
var _atlas_coords: Vector2i
var _appear: Appear

var appear_disappear_duration: float = 1
var time_elapsed: float = 0
var appearing = true

func init(appear: Appear, atlas: Texture, atlas_coords: Vector2i, tile_map: TileMapLayer, coords: Vector2i):
	_tile_map = tile_map
	_coords = coords
	_atlas_coords = atlas_coords
	_appear = appear
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i((atlas_coords * Settings.tile_size), Settings.tile_size)

func _process(delta):
	if appearing:
		time_elapsed += delta
	else:
		time_elapsed -= delta
	if time_elapsed >= appear_disappear_duration:
		appearing = false
	elif time_elapsed < 0:
		_on_anim_complete()
		return

	sprite.modulate.a = lerp(0, 1, time_elapsed / appear_disappear_duration)

func reinit():
	reappear_check()
					
func reappear_check():
	if appearing == false:
		appearing = true
		time_elapsed = sprite.modulate.a * appear_disappear_duration
		

func _on_anim_complete():
	if _appear != null:
		_appear.remove_from_appear_dict(_coords)
	queue_free()
