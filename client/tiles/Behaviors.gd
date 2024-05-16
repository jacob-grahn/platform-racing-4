class_name Behaviors


################
# Push
################
static var push_force = 75 # used for gliding up/down/left/right
static var push_force_stand = 600 # used for standing, bumps you up into the air
static var push_force_bump = 75 #
static var phantom_push_force_bump = 260
static var phantom_push_force_bump_decay = 0.8
static var vector_up = Vector2(0, -1)
static var vector_down = Vector2(0, 1)
static var vector_left = Vector2(-1, 0)
static var vector_right = Vector2(1, 0)

static func push_up(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_up)

static func push_down(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_down)
		
static func push_left(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_left)

static func push_right(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_right)
		
static func push(node: Node2D, target: Node2D, coords: Vector2i, push_dir: Vector2):
	if "velocity" not in node:
		return
		
	var rotated_push_dir = push_dir.rotated(target.global_rotation)
	var target_global_position = target.to_global((coords * 128) + Vector2i(64, 64)) 
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
	

###################
# Set Velocity
###################
static var insta_force = 1400

static func insta_up(node: Node2D, target: Node2D, coords: Vector2i)->void:
	insta(node, target, coords, vector_up)

static func insta_left(node: Node2D, target: Node2D, coords: Vector2i)->void:
	insta(node, target, coords, vector_left)

static func insta_right(node: Node2D, target: Node2D, coords: Vector2i)->void:
	insta(node, target, coords, vector_right)

static func insta_down(node: Node2D, target: Node2D, coords: Vector2i)->void:
	insta(node, target, coords, vector_down)

static func insta(node: Node2D, target: Node2D, coords: Vector2i, direction: Vector2):
	if "velocity" in node:
		node.velocity = direction.rotated(target.global_rotation) * insta_force
		

##################
# area switch
##################
static func ares_switch(node: Node2D, tilemap: Node2D, _coords: Vector2i)->void:
	var gear_list = tilemap.get_used_cells_by_id(0, 0, Vector2i(4, 3))
	if len(gear_list) > 0:
		var rotation_controller = tilemap.get_parent()
		rotation_controller.enabled_temp = true
