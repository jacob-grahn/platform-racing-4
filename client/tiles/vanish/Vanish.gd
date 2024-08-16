extends Tile
class_name Vanish

const VANISH_EFFECT = preload("res://tiles/vanish/VanishEffect.tscn")

var anim_fading_time = float(0.3)   #Default 0.3
var anim_gone_time = float(1.995)   #Default 1.995
var anim_unfading_time = float(0.3) #Default 0.3

var anim_fading_end_time = float(anim_fading_time + anim_gone_time)
var anim_unfading_end_time = float(anim_fading_end_time + anim_unfading_time)
var anim_player
var anim
var anim_timeline_position

func init():
	matter_type = Tile.SOLID
	any_side.push_back(vanish)
	is_safe = false

func vanish(player: Node2D, tilemap: TileMap, coords: Vector2i):
	if tilemap.get_cell_alternative_tile(0,coords) != 0: #Only pass if statement when the Vanish Block is in default tile state
		anim_timeline_position = anim_player.get_current_animation_position()
		if anim_timeline_position > anim_fading_time + anim_gone_time: #Check if Vanish is mid-appear phase to start despawning it
			anim_player.seek(max(0, anim_fading_time + anim_gone_time + anim_unfading_time - anim_timeline_position))
		return #Return if vanish is currently despawning
	
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	tilemap.set_cell(0, coords, 0, atlas_coords, 1)
	var tile_atlas = tilemap.tile_set.get_source(0).texture
	var vanish_effect = VANISH_EFFECT.instantiate()
	vanish_effect.position = coords * Settings.tile_size
	tilemap.add_child(vanish_effect)
	vanish_effect.init(tile_atlas, atlas_coords, tilemap, coords)
	
	anim_player = vanish_effect.get_node("AnimationPlayer")
	anim = anim_player.get_animation("vanish")
	anim.length = anim_unfading_end_time #Total length
	#Insert Keys into Sprite modulate Track
	anim.track_insert_key(0,float(0),Color(1, 1, 1, 1),1) #Start Disappear
	anim.track_insert_key(0,anim_fading_time,Color(1, 1, 1, 0), 1) #End Disappear
	anim.track_insert_key(0,anim_fading_end_time,Color(1, 1, 1, 0),1) #Start Reappear
	anim.track_insert_key(0,anim_unfading_end_time,Color(1, 1, 1, 1),1) #End Reappear
	#Insert Keys into Node Call Functions Track
	anim.track_insert_key(2,anim_fading_end_time - 0.1,{"method" : "_avoid_clobber", "args" : []})
	anim.track_insert_key(2,anim_fading_time,{"method" : "_on_disappear", "args" : []})
	anim.track_insert_key(2,anim_fading_end_time,{"method" : "_on_reappear", "args" : []})
	anim.track_insert_key(2,anim_unfading_end_time,{"method" : "_on_anim_complete", "args" : []})
	
