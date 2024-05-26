extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = -1600.0
const TRACTION = 2500
const FRICTION = 0.1
const LIGHTBREAK_SPEED = 200000.0
const LightLine2D = preload("res://tiles/lights/LightLine2D.tscn")

@onready var short_shape = $ShortShape
@onready var tall_shape = $TallShape
@onready var light = $Light
@onready var camera = $Camera
@onready var sun_particles = $SunParticles
@onready var moon_particles = $MoonParticles

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var active = false
var control_vector: Vector2
var crouched = false

# Lightbreak
var lightbreak_direction: Vector2 = Vector2(0, 0)
var lightbreak_windup: float = 0
var lightbreak_input_primed: bool = false
var lightbreak_src_tile: Vector2i
var lightbreak_type: String = ""
var lightbreak_line: Node2D
var lightbreak_fire_power: int = 0
var lightbreak_moon_timer: float = 0

# Camera
var camera_target_zoom: float = 1.0
var camera_zoom_speed: float = 0.6
var camera_max_zoom: float = 1.0
var camera_min_zoom: float = 0.8
var camera_zoom_smoothing: float = 0.1 # smaller is smoother, slower

# Use this to apply a longer velocity shift
var phantom_velocity: Vector2 = Vector2(0 , 0)
var phantom_velocity_decay: float = 0.25

# Used to carry the player along with rotating platforms
var rotating_platform_velocity: Vector2 = Vector2(0, 0)

# list of incopereal tile rids that are overlapping this character's area
var incoporeal_rids = []


func _ready():
	$Area2D.connect("body_shape_entered", _on_body_shape_entered)
	$Area2D.connect("body_shape_exited", _on_body_shape_exited)


func _physics_process(delta):
	if !active:
		return
	
	# default to standing
	crouched = false
	if lightbreak_windup > 0:
		crouched = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Inputs
	control_vector = Input.get_vector("left", "right", "up", "down")

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and velocity.y > JUMP_VELOCITY * 0.75:
		velocity.y += JUMP_VELOCITY
	
	# Lame super jump
	if Input.is_action_pressed("down") and is_on_floor() and velocity.y > JUMP_VELOCITY * 0.75:
		velocity.y += JUMP_VELOCITY * 1.5
	
	# Move left / right
	var target_speed = control_vector.x * SPEED
	if control_vector.x != 0:
		if (target_speed > 0 && target_speed > velocity.x) || target_speed < 0 && target_speed < velocity.x:
			velocity.x = move_toward(velocity.x, target_speed, delta * TRACTION)
	else:
		velocity.x = move_toward(velocity.x, 0, delta * TRACTION * 0.8)
	
	# Add friction
	velocity = velocity * (1 - (FRICTION * delta))
	
	# Add velocity boost
	velocity += phantom_velocity
	phantom_velocity = phantom_velocity * phantom_velocity_decay
	
	#
	position += rotating_platform_velocity * delta * 1
	velocity += rotating_platform_velocity * delta * 20
	rotating_platform_velocity = Vector2(0, 0)
	
	# lightbreak cooldown
	if lightbreak_windup > 0:
		lightbreak_windup -= delta
		if lightbreak_windup <= 0:
			lightbreak_src_tile = Vector2i(0, 0)
			lightbreak_input_primed = false
	
	# manage character light
	if lightbreak_windup > 0 || lightbreak_direction.length() > 0:
		light.enabled = true
		if lightbreak_direction.length() > 0:
			light.energy = 0.5
		else:
			light.energy = lightbreak_windup / 2
	else:
		light.enabled = false
	
	# camera
	if lightbreak_windup > 0 || lightbreak_direction.length() > 0:
		if camera_target_zoom > camera_min_zoom:
			camera_target_zoom -= camera_zoom_speed * delta
		if camera_target_zoom < camera_min_zoom:
			camera_target_zoom = camera_min_zoom
	else:
		if camera_target_zoom < camera_max_zoom:
			camera_target_zoom += camera_zoom_speed * delta
		if camera_target_zoom > camera_max_zoom:
			camera_target_zoom = camera_max_zoom
	camera.zoom.x += (camera_target_zoom - camera.zoom.x) * camera_zoom_smoothing
	camera.zoom.y += (camera_target_zoom - camera.zoom.y) * camera_zoom_smoothing
	
	# lightbreak
	if lightbreak_direction.length() > 0:
		velocity = lightbreak_direction * LIGHTBREAK_SPEED * delta
		crouched = true
		if (control_vector + lightbreak_direction).length() < 0.5:
			end_lightbreak()
	
	# firefly
	if lightbreak_type == LightTile.FIREFLY:
		if lightbreak_direction.length() > 0:
			if !lightbreak_line:
				lightbreak_line = LightLine2D.instantiate()
				get_parent().add_child(lightbreak_line)
			lightbreak_line.add_point(position)
		if control_vector.length() > 0:
			if (control_vector + lightbreak_direction).length() > 0.5:
				lightbreak_direction = control_vector
	
	# sun
	if lightbreak_type == LightTile.SUN:
		if lightbreak_direction.length() > 0:
			sun_particles.emitting = true
	
	# use crouch hitbox if not moving up
	if velocity.y >= 0:
		crouched = true
	
	# change hitbox if crouched
	short_shape.disabled = !crouched
	tall_shape.disabled = crouched
	
	# moon
	if lightbreak_type == LightTile.MOON && lightbreak_direction.length() > 0:
		short_shape.disabled = true
		tall_shape.disabled = true
		modulate.a = randf_range(0, 0.66)
		lightbreak_moon_timer -= delta
		moon_particles.emitting = true
		if lightbreak_moon_timer < 0 && !is_in_solid():
			end_lightbreak()
	
	#
	move_and_slide()
	
	# interact with tiles
	interact_with_incoporeal_tiles()
	var hit_something = interact_with_solid_tiles()
	
	# end lightbreak if you hit a wall
	if hit_something && lightbreak_direction.length() > 0:
		end_lightbreak()


func end_lightbreak():
	lightbreak_direction = Vector2(0, 0)
	lightbreak_type = ""
	lightbreak_line = null
	lightbreak_fire_power = 0
	sun_particles.emitting = false
	modulate.a = 1
	lightbreak_moon_timer = 0
	moon_particles.emitting = false


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
		Game.game.tiles.on("area", tile_type, self, tilemap, coords)
	

# Interact with tiles like walls, arrows, etc
func interact_with_solid_tiles() -> bool:
	var collision = get_last_slide_collision()
	if !collision:
		return false
		
	var tilemap = collision.get_collider()
	if tilemap.get_class() != "TileMap":
		return false
	
	var normal = collision.get_normal()
	var rid = collision.get_collider_rid()
	var coords = tilemap.get_coords_for_body_rid(rid)
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	var tile_type = atlas_coords.x + (atlas_coords.y * 10)
	var game = Game.game
	
	if abs(normal.x) > abs(normal.y):
		if normal.x > 0:
			game.tiles.on("left", tile_type, self, tilemap, coords)
			game.tiles.on("any_side", tile_type, self, tilemap, coords)
		else:
			game.tiles.on("right", tile_type, self, tilemap, coords)
			game.tiles.on("any_side", tile_type, self, tilemap, coords)
	else:
		if normal.y > 0:
			game.tiles.on("bottom", tile_type, self, tilemap, coords)
			game.tiles.on("any_side", tile_type, self, tilemap, coords)
			game.tiles.on("bump", tile_type, self, tilemap, coords)
		else:
			game.tiles.on("top", tile_type, self, tilemap, coords)
			game.tiles.on("any_side", tile_type, self, tilemap, coords)
			game.tiles.on("stand", tile_type, self, tilemap, coords)
		
	# Account for rotating tiles
	if tilemap.get_parent() is RotationController:
		var rotation_controller = tilemap.get_parent()
		var tile_position = tilemap.to_global(coords * 128 + Vector2i(64, 64))
		rotating_platform_velocity = calculate_velocity(rotation_controller.position, tile_position, rotation_controller.rotation_velocity)
		game.get_node('BlockPoint').position = tile_position
		game.get_node('PlayerPoint').position = tile_position + rotating_platform_velocity / 10
	
	# blow up tiles when sun lightbreaking
	if lightbreak_direction.length() > 0 && lightbreak_fire_power > 0:
		tilemap.set_cell(-1, coords)
		lightbreak_fire_power -= 1
		return false
	else:
		return true


# Function to calculate the tangential velocity at a subject point
# due to rotation around an origin point.
func calculate_velocity(origin_point, subject_point, rotation_velocity):
	# Calculate the direction from the origin to the subject
	var direction = subject_point - origin_point
	
	# Calculate the radius of the rotation
	var radius = direction.length()
	
	# Calculate the angle of the direction vector
	var angle = direction.angle()
	
	# Calculate the new angle by adding 90 degrees (π/2 radians)
	# to make the velocity vector perpendicular to the radius
	var new_angle = angle + PI / 2
	
	# Calculate the velocity components using the new angle
	# Note: rotation_velocity is assumed to be in radians per second
	var vx = rotation_velocity * radius * cos(new_angle)
	var vy = rotation_velocity * radius * sin(new_angle)
	
	# Return the velocity as a Vector2
	return Vector2(vx, vy)


# Interact with tiles like water, switches, etc
func is_in_solid() -> bool:
	var in_solid = false
	for shape in incoporeal_rids:
		var rid: RID = shape["body_rid"]
		var tilemap: TileMap = shape["body"]
		var coords = tilemap.get_coords_for_body_rid(rid)
		var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
		var tile_type = atlas_coords.x + (atlas_coords.y * 10)
		if Game.game.tiles.is_solid(tile_type):
			in_solid = true
	return in_solid
