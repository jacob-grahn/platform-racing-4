extends CharacterBody2D

const SPEED = 1000.0
const JUMP_VELOCITY = Vector2(0, -1600.0)
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
@onready var area = $Area
@onready var item_holder = $ItemHolder
@onready var ice = $Ice

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: Vector2 = Vector2(0, ProjectSettings.get_setting("physics/2d/default_gravity"))
var gravity_rotated: Vector2 = gravity.rotated(rotation)
var base_up_direction = Vector2(0, -1)
var active = false
var control_vector: Vector2
var crouched = false
var game: Node2D
var previous_velocity = Vector2(0 , 0)
var last_collision: KinematicCollision2D
var target_rotation: float = 0
var rotate_speed: float = 0.05
var item: Node2D
var last_safe_position = Vector2(0, 0)
var frozen_timer: float = 0.0

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
var camera_target_zoom: float = 0.2
var camera_zoom_speed: float = 0.6
var camera_max_zoom: float = 1.0
var camera_min_zoom: float = 0.8
var camera_zoom_smoothing: float = 0.1 # smaller is smoother, slower

# Use this to apply a longer velocity shift
var phantom_velocity: Vector2 = Vector2(0 , 0)
var phantom_velocity_decay: float = 0.25

# list of incopereal tile rids that are overlapping this character's area
var incoporeal_rids = []


func _ready():
	game = get_parent().get_parent().get_parent().get_parent()
	area.connect("body_shape_entered", _on_body_shape_entered)
	area.connect("body_shape_exited", _on_body_shape_exited)
	last_safe_position = Vector2(position)


func _physics_process(delta):
	if !active:
		return
	
	# default to standing
	crouched = false
	if lightbreak_windup > 0:
		crouched = true
	
	# frozen timer
	var traction = TRACTION
	if frozen_timer >= 0:
		frozen_timer -= delta
		ice.visible = true
		traction = TRACTION / 10
	else:
		ice.visible = false
	
	# Rotate
	if rotation != target_rotation:
		var rotation_dist = clamp(rotation - target_rotation, -rotate_speed, rotate_speed)
		if abs(rotation_dist) < rotate_speed:
			rotation = target_rotation
			target_rotation = rotation # deal with rotation switching from negative to positive
		else:
			rotation -= rotation_dist
		gravity_rotated = gravity.rotated(rotation)
		up_direction = base_up_direction.rotated(rotation)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += gravity_rotated * delta
	
	# Inputs
	control_vector = Input.get_vector("left", "right", "up", "down")

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor() and velocity.rotated(-rotation).y > JUMP_VELOCITY.y * 0.75:
		velocity += JUMP_VELOCITY.rotated(rotation)
	
	# Lame super jump
	if Input.is_action_pressed("down") and is_on_floor() and velocity.rotated(-rotation).y > JUMP_VELOCITY.y * 0.75:
		velocity += JUMP_VELOCITY.rotated(rotation) * 1.5
	
	# Move left / right
	var target_velocity = Vector2(control_vector.x * SPEED, velocity.rotated(-rotation).y).rotated(rotation)
	if control_vector.x != 0:
		if (target_velocity.length() > velocity.length()):
			velocity = velocity.move_toward(target_velocity, delta * traction)
	else:
		velocity = velocity.move_toward(target_velocity, delta * traction * 0.8)
	
	# Add friction
	velocity = velocity * (1 - (FRICTION * delta))
	
	# Add velocity boost
	velocity += phantom_velocity
	phantom_velocity = phantom_velocity * phantom_velocity_decay
	
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
	if velocity.rotated(-rotation).y >= 0:
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
	
	# disable collision if we're stuck in a wall
	if is_in_solid():
		short_shape.disabled = true
		tall_shape.disabled = true
		
	# move
	previous_velocity = velocity
	move_and_slide()
	
	# interact with tiles
	interact_with_incoporeal_tiles()
	var hit_something = interact_with_solid_tiles()
	
	# end lightbreak if you hit a wall
	if hit_something && lightbreak_direction.length() > 0:
		end_lightbreak()
	
	# Use items
	if Input.is_action_pressed("item"):
		use_item(delta)


func freeze():
	frozen_timer = 1.0


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
		var tile_type = Helpers.to_block_id(atlas_coords)
		game.tiles.on("area", tile_type, self, tilemap, coords)
	

# Interact with tiles like walls, arrows, etc
func interact_with_solid_tiles() -> bool:
	var collision: KinematicCollision2D = get_last_slide_collision()
	last_collision = collision
	if !collision:
		return false
		
	var tilemap = collision.get_collider()
	if tilemap.get_class() != "TileMap":
		return false
	
	var normal = collision.get_normal().rotated(-rotation)
	var rid = collision.get_collider_rid()
	var coords = tilemap.get_coords_for_body_rid(rid)
	var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	var tile_type = Helpers.to_block_id(atlas_coords)
	
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
			if game.tiles.is_safe(tile_type):
				last_safe_position = Vector2(floor(position.x / Settings.tile_size.x) * Settings.tile_size.x, position.y) - Vector2(-Settings.tile_size_half.x, Settings.tile_size_half.y).rotated(rotation)
	
	# blow up tiles when sun lightbreaking
	if lightbreak_direction.length() > 0 && lightbreak_fire_power > 0:
		TileEffects.shatter(tilemap, coords)
		lightbreak_fire_power -= 1
		return false
	else:
		return true


# Interact with tiles like water, switches, etc
func is_in_solid() -> bool:
	var in_solid = false
	for shape in incoporeal_rids:
		var rid: RID = shape["body_rid"]
		var tilemap: TileMap = shape["body"]
		var coords = tilemap.get_coords_for_body_rid(rid)
		var atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
		var tile_type = Helpers.to_block_id(atlas_coords)
		if game.tiles.is_solid(tile_type):
			in_solid = true
	return in_solid


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32(depth * 2)
	var vapor_layer = Helpers.to_bitmask_32((depth * 2) + 1)
	collision_layer = solid_layer
	collision_mask = solid_layer
	area.collision_layer = vapor_layer
	area.collision_mask = solid_layer | vapor_layer


func set_item(new_item: Node2D) -> void:
	if item:
		remove_item()
	
	item = new_item
	item_holder.add_child(item)


func remove_item() -> void:
	if item:
		item.queue_free()
		item = null


func use_item(delta: float) -> void:
	if item:
		var has_more_uses: bool = item.use(delta)
		if !has_more_uses:
			remove_item()
