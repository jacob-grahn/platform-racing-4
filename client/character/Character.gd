extends CharacterBody2D


const SPEED = 1000.0
const JUMP_VELOCITY = -1600.0
const TRACTION = 2500
const FRICTION = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var active = false

# Use this to apply a longer velocity shift
var phantom_velocity: Vector2 = Vector2(0 , 0)
var phantom_velocity_decay: float = 0.25

# list of incopereal tile rids that are overlapping this character's area
var incoporeal_rids = []


func _ready():
	$Area2D.connect("body_shape_entered", _on_body_shape_entered)
	$Area2D.connect("body_shape_exited", _on_body_shape_exited)


func _physics_process(delta):
	if !active:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("ui_up") and is_on_floor() and velocity.y > JUMP_VELOCITY * 0.75:
		velocity.y += JUMP_VELOCITY
	
	# Lame super jump
	if Input.is_action_pressed("ui_down") and is_on_floor() and velocity.y > JUMP_VELOCITY * 0.75:
		velocity.y += JUMP_VELOCITY * 1.5
	
	var direction = Input.get_axis("ui_left", "ui_right")
	var target_speed = direction * SPEED
	if direction:
		if (target_speed > 0 && target_speed > velocity.x) || target_speed < 0 && target_speed < velocity.x:
			velocity.x = move_toward(velocity.x, target_speed, delta * TRACTION)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * TRACTION * 0.8)
	
	#
	move_and_slide()
	
	# Add friction
	velocity = velocity * (1 - (FRICTION * delta))
	
	# Add velocity boost
	velocity += phantom_velocity
	phantom_velocity = phantom_velocity * phantom_velocity_decay
	
	interact_with_incoporeal_tiles()
	interact_with_solid_tiles()


func _on_body_shape_entered(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int):
	if body.get_class() != "TileMap":
		return
	incoporeal_rids.push_back({"body_rid": body_rid, "body": body})


func _on_body_shape_exited(body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int):
	incoporeal_rids = incoporeal_rids.filter(func(dict): return dict["body_rid"] != body_rid)


# Interact with tiles like water, switches, etc
func interact_with_incoporeal_tiles():
	for shape in incoporeal_rids:
		var rid: RID = shape["body_rid"]
		var tilemap: TileMap = shape["body"]
		var coords = tilemap.get_coords_for_body_rid(rid)
		var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
		var tile_type = atlas_coords.x + (atlas_coords.y * 10)
		Game.game.tile_behaviors.on("area", tile_type, self, tilemap, coords)
	

# Interact with tiles like walls, arrows, etc
func interact_with_solid_tiles():
	var collision = get_last_slide_collision()
	if !collision:
		return
		
	var collider = collision.get_collider()
	if collider.get_class() != "TileMap":
		return
	
	var normal = collision.get_normal()
	var rid = collision.get_collider_rid()
	var coords = collider.get_coords_for_body_rid(rid)
	var atlas_coords = collider.get_cell_atlas_coords(0, coords)
	var tile_type = atlas_coords.x + (atlas_coords.y * 10)
	var game = Game.game
	
	if abs(normal.x) > abs(normal.y):
		if normal.x > 0:
			game.tile_behaviors.on("left", tile_type, self, collider, coords)
			game.tile_behaviors.on("any_side", tile_type, self, collider, coords)
		else:
			game.tile_behaviors.on("right", tile_type, self, collider, coords)
			game.tile_behaviors.on("any_side", tile_type, self, collider, coords)
	else:
		if normal.y > 0:
			game.tile_behaviors.on("bottom", tile_type, self, collider, coords)
			game.tile_behaviors.on("any_side", tile_type, self, collider, coords)
			game.tile_behaviors.on("bump", tile_type, self, collider, coords)
		else:
			game.tile_behaviors.on("top", tile_type, self, collider, coords)
			game.tile_behaviors.on("any_side", tile_type, self, collider, coords)
			game.tile_behaviors.on("stand", tile_type, self, collider, coords)
