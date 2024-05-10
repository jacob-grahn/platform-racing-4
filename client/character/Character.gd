extends CharacterBody2D


const SPEED = 900.0
const JUMP_VELOCITY = -1500.0
const TRACTION = 2500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var active = false
var game: Game
var tile_map: TileMap


func _ready():
	game = get_parent() # todo, messy
	tile_map = game.get_node("TileMap")


func _physics_process(delta):
	if !active:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Lame super jump
	if Input.is_action_pressed("ui_down") and is_on_floor():
		velocity.y = JUMP_VELOCITY * 1.5
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * TRACTION)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * TRACTION * 0.8)
	
	# Interact with tiles
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var normal = collision.get_normal()
		var rid = collision.get_collider_rid()
		var coords = tile_map.get_coords_for_body_rid(rid)
		var atlas_coords = tile_map.get_cell_atlas_coords(0, coords)
		var tile_type = atlas_coords.x + (atlas_coords.y * 10)

		if abs(normal.x) > abs(normal.y):
			if normal.x > 0:
				game.tile_behaviors.on("left", tile_type, self, coords)
				game.tile_behaviors.on("any_side", tile_type, self, coords)
			else:
				game.tile_behaviors.on("right", tile_type, self, coords)
				game.tile_behaviors.on("any_side", tile_type, self, coords)
		else:
			if normal.y > 0:
				game.tile_behaviors.on("bottom", tile_type, self, coords)
				game.tile_behaviors.on("any_side", tile_type, self, coords)
				game.tile_behaviors.on("bump", tile_type, self, coords)
			else:
				game.tile_behaviors.on("top", tile_type, self, coords)
				game.tile_behaviors.on("any_side", tile_type, self, coords)
				game.tile_behaviors.on("stand", tile_type, self, coords)
		

	move_and_slide()
