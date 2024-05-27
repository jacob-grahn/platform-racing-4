extends Tile
class_name Arrow

var ArrowActivateEffect: PackedScene = preload("res://tiles/arrows/ArrowActivateEffect.tscn")
var push_force = 75 # used for gliding up/down/left/right
var push_force_stand = 600 # used for standing, bumps you up into the air
var push_force_bump = 75 #
var phantom_push_force_bump = 260
var phantom_push_force_bump_decay = 0.8


func init():
	matter_type = Tile.SOLID


func push(node: Node2D, tilemap: Node2D, coords: Vector2i, push_dir: Vector2):
	if "velocity" not in node:
		return
		
	var rotated_push_dir = push_dir.rotated(tilemap.global_rotation)
	var target_global_position = tilemap.to_global((coords * 128) + Vector2i(64, 64)) 
	var player_global_position = node.to_global(Vector2(0, -100))
	var player_dir = (player_global_position - target_global_position).normalized()
	var cross = rotated_push_dir.cross(player_dir)
	
	# player is perpendicular, running across or sliding up/down
	if abs(cross) > 0.5:
		node.velocity += rotated_push_dir * push_force
	
	# player is standing or bumping on the block
	else:
		if abs(node.rotation - rotated_push_dir.rotated(PI/2).angle()) < 0.1:
			if node.is_on_floor():
				print('extra push')
				node.velocity += rotated_push_dir * push_force_stand
			else:
				print('phantom')
				node.velocity += rotated_push_dir * push_force
				node.phantom_velocity = rotated_push_dir * phantom_push_force_bump
				node.phantom_velocity_decay = phantom_push_force_bump_decay
		else:
			node.velocity += rotated_push_dir * push_force
	
	var game = Game.game
	game.get_node("PlayerPoint").position = Vector2(player_global_position)
	game.get_node("BlockPoint").position = Vector2(target_global_position)
	
	# add effect
	var effect_name = str(coords.x) + "-" + str(coords.y) + "-arrow"
	var holder = tilemap.get_parent()
	var existing_effect = holder.get_node(effect_name)
	if existing_effect:
		existing_effect.get_node("AnimationPlayer").seek(0)
		return
	var effect = ArrowActivateEffect.instantiate()
	var global_pos = tilemap.to_global((coords * Settings.tile_size) + Settings.tile_size_half)
	effect.position = holder.to_local(global_pos)
	effect.rotation = push_dir.rotated(-PI / 2).angle()
	effect.name = effect_name
	holder.add_child(effect)
