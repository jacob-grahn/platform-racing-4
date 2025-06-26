extends Node2D
class_name VanishEffect

# Assumes AnimationPlayer's "vanish" and "appear" animations have the same length

@onready var sprite = $Sprite
@onready var area: Area2D = $Area
@onready var animation_player = $AnimationPlayer
@onready var invisibility_timer = $InvisibilityTimer

var _tile_map: TileMap
var _coords: Vector2i
var _atlas_coords: Vector2i
var _vanish: Vanish


func _exit_tree() -> void:
	_vanish.remove_from_vanish_dict(_coords)
	_tile_map.set_cell(0, _coords, 0, _atlas_coords, 0)

func init(vanish: Vanish, atlas: Texture, atlas_coords: Vector2i, tile_map: TileMap, coords: Vector2i) -> void:
	
	_tile_map = tile_map
	_coords = coords
	_atlas_coords = atlas_coords
	_vanish = vanish
	
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i(atlas_coords * Settings.tile_size, Settings.tile_size)
	
	# Set mask to detect character layer for the same depth
	var depth = Globals.Helpers.get_depth(tile_map)
	var layer = Globals.Helpers.to_bitmask_32(depth * 2 - 1)
	area.collision_mask = layer

func vanish_again() -> void:
	
	if !animation_player.is_playing():
		return
	
	if animation_player.assigned_animation != "appear":
		return
	
	var progress = animation_player.get_current_animation_position()
	
	# Edge case when the player touches a block right as it were going to appear
	if progress == 0:
		return
	
	var duration = animation_player.get_animation("appear").length
	
	animation_player.play("vanish")
	animation_player.seek(duration - progress)

func _try_to_appear() -> void:
	
	if animation_player.is_playing():
		return
	
	if !invisibility_timer.is_stopped():
		return
	
	for body in area.get_overlapping_bodies():
		if body is Character: # TODO: Ignore if wearing top hat
			return
	
	_tile_map.set_cell(0, _coords, 0, _atlas_coords,1)
	animation_player.play("appear")

func _on_animation_player_animation_finished(animation_name: StringName) -> void:
	match animation_name:
		"vanish":
			_tile_map.set_cell(0, _coords, 0, _atlas_coords, 4)
			invisibility_timer.start()
		"appear":
			queue_free()

func _on_invisibility_timer_timeout() -> void:
	_try_to_appear()

func _on_area_body_exited(_body) -> void:
	_try_to_appear()
