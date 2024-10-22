extends CharacterBody2D
class_name Character

const SPEED = 975.0
const JUMP_VELOCITY = Vector2(0, -375.0)
const FASTFALL_VELOCITY = Vector2(0, 65.0)
const MAXFALL_VELOCITY = 6500.0
const SWIM_UP_VELOCITY = Vector2(0, -SPEED * 6)
const TRACTION = 2500
const FRICTION = 0.1
const FRICTION_SWIMMING = 4.0
const LIGHTBREAK_SPEED = 200000.0
const JUMP_VELOCITY_MULTIPLIER = 0.75
const JUMP_TIMER_MAX = 10.0
const LightLine2D = preload("res://tiles/lights/LightLine2D.tscn")

@onready var hitbox = $CharacterHitbox
@onready var light = $Light
@onready var camera = $Camera
@onready var sun_particles = $SunParticles
@onready var moon_particles = $MoonParticles
@onready var low_area = $LowArea
@onready var high_area = $HighArea
@onready var item_holder = $ItemHolder
@onready var ice = $Ice
@onready var shield = $Shield
@onready var display = $Display
@onready var animations: AnimationPlayer = $Animations

var active = false
var control_vector: Vector2
var jump_timer: float = 0
var jumped = false
var can_move = true
var can_jump = true
var is_crouching = false
var game: Node2D
var previous_velocity = Vector2(0 , 0)
var last_collision: KinematicCollision2D
var item: Node2D
var last_safe_position = Vector2(0, 0)
var last_safe_layer: Node
var frozen_timer: float = 0.0
var last_velocity: Vector2
var last_collision_normal: Vector2
var swimming: bool = false
var stats: Stats = Stats.new()
var super_jump: SuperJump = SuperJump.new()
var gravity: Gravity = Gravity.new()

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
var camera_target_zoom: float = 0.1
var camera_zoom_speed: float = 0.6
var camera_max_zoom: float = 0.5
var camera_min_zoom: float = 0.4
var camera_zoom_smoothing: float = 0.1 # smaller is smoother, slower

# Use this to apply a longer velocity shift
var phantom_velocity: Vector2 = Vector2(0 , 0)
var phantom_velocity_decay: float = 0.25


func _ready():
	game = get_parent().get_parent().get_parent().get_parent()
	last_safe_position = Vector2(position)


func _physics_process(delta):
	if !active:
		return
	
	# crouch under stuff
	is_crouching = should_crouch()
	
	# hitbox resizes based on things
	hitbox.run(self)
	
	# frozen timer
	var traction = TRACTION
	if frozen_timer >= 0:
		frozen_timer -= delta
		ice.visible = true
		traction = TRACTION / 10.0
	else:
		ice.visible = false
	
	# Gravity
	gravity.run(self, delta)
	
	# Inputs
	var control_axis: float = Input.get_axis("left", "right")

	# Super jump
	super_jump.run(self, delta)
	
	# Handle jump.
	if can_jump and Input.is_action_pressed("jump"):
		
		if is_crouching:
			_bump_tile_covering_high_area()
		
		elif is_on_floor() and velocity.rotated(-rotation).y > JUMP_VELOCITY.y * JUMP_VELOCITY_MULTIPLIER:
			jumped = true
			jump_timer = JUMP_TIMER_MAX
	
	# Handle jump strength/velocity increment
	if jumped:
		velocity += JUMP_VELOCITY.rotated(rotation) * stats.get_jump_bonus() * (jump_timer / JUMP_TIMER_MAX)
		jump_timer -= 1
		if jump_timer <= 0:
			jumped = false
			jump_timer = 0
	# Caps falling velocity.
	if abs(velocity.y) > MAXFALL_VELOCITY:
		if velocity.y > 0:
			velocity.y = MAXFALL_VELOCITY
		else:
			velocity.y = MAXFALL_VELOCITY * -1
		
	# Airborne behavior
	if not is_on_floor():
		# Cancel jump early by not pressing jump.
		if jumped and not Input.is_action_pressed("jump"):
			jumped = false
		# Fastfall; if down pressed while not on floor, fall faster
		if Input.is_action_pressed("down"):
			velocity += FASTFALL_VELOCITY.rotated(rotation)
			jumped = false
		# if in liquid, we can swim up
		if swimming && Input.is_action_pressed("up"):
			velocity += SWIM_UP_VELOCITY.rotated(rotation) * delta
		# extra jump is gone after releasing jump button
		if not jumped:
			jump_timer = 0
	
	# Move left/right
	if super_jump.is_locking():
		control_axis = 0
	if is_crouching:
		control_axis = control_axis / 2
	var target_velocity = Vector2(control_axis * SPEED * stats.get_speed_bonus(), velocity.rotated(-rotation).y).rotated(rotation)
	if control_axis != 0:
		if target_velocity.length() > velocity.length():
			traction *= 0.8
		velocity = velocity.move_toward(target_velocity, delta * traction)
	else:
		velocity = velocity.move_toward(target_velocity, delta * traction * 0.8)
	
	# Add friction
	var friction = FRICTION
	if swimming:
		friction = FRICTION_SWIMMING
	velocity = velocity * (1 - (friction * delta))
	
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
	control_vector = Input.get_vector("left", "right", "up", "down")
	if lightbreak_direction.length() > 0:
		velocity = lightbreak_direction * LIGHTBREAK_SPEED * delta
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
	
	# moon
	if lightbreak_type == LightTile.MOON && lightbreak_direction.length() > 0:
		modulate.a = randf_range(0, 0.66)
		lightbreak_moon_timer -= delta
		moon_particles.emitting = true
		if lightbreak_moon_timer < 0 && !is_in_solid():
			end_lightbreak()
		
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
	
	# Save velocity for a cycle
	last_velocity = Vector2(velocity)
	
	# Look good
	update_animation()


# When you try to jump while crouching
func _bump_tile_covering_high_area() -> void:
	
	var tiles: Array = get_tiles_overlapping_area(high_area)
	
	if tiles.size() == 0:
		push_error("Character::_bump_tile_covering_high_area - No tile covering high area")
		return
	
	var tile = tiles[0]
	var tile_type = Helpers.to_block_id(tile.atlas_coords)
	
	game.tiles.on("bottom", tile_type, self, tile.tile_map, tile.coords)
	game.tiles.on("any_side", tile_type, self, tile.tile_map, tile.coords)
	game.tiles.on("bump", tile_type, self, tile.tile_map, tile.coords)


func freeze():
	frozen_timer = 1.0 / stats.get_skill_bonus()


func end_lightbreak():
	lightbreak_direction = Vector2(0, 0)
	lightbreak_type = ""
	lightbreak_line = null
	lightbreak_fire_power = 0
	sun_particles.emitting = false
	modulate.a = 1
	lightbreak_moon_timer = 0
	moon_particles.emitting = false


func get_tiles_overlapping_area(area: Area2D):
	var tiles = []
	var bodies: Array = area.get_overlapping_bodies()
	for tile_map in bodies:
		if !(tile_map is TileMap):
			continue
		var coords = tile_map.local_to_map(tile_map.to_local(area.to_global(Vector2.ZERO)))
		var atlas_coords = tile_map.get_cell_atlas_coords(0, coords)
		var block_id = Helpers.to_block_id(atlas_coords)
		if block_id != 0:
			tiles.push_back({
				"tile_map": tile_map,
				"coords": coords,
				"atlas_coords": atlas_coords,
				"block_id": block_id
			})
	return tiles
	

# Interact with tiles like water, switches, etc
func interact_with_incoporeal_tiles():
	swimming = false
	var tiles: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles:
		if game.tiles.is_liquid(tile.block_id):
			swimming = true
		game.tiles.on("area", tile.block_id, self, tile.tile_map, tile.coords)


# Are we in a wall?
func is_in_solid() -> bool:
	var tiles: Array = get_tiles_overlapping_area(low_area)
	for tile in tiles:
		if game.tiles.is_solid(tile.block_id):
			return true
	return false


# should crouch
func should_crouch():
	if !is_crouching && !is_on_floor():
		return false
	var tiles: Array = get_tiles_overlapping_area(high_area)
	for tile_data in tiles:
		if game.tiles.is_solid(tile_data.block_id):
			return true
	return false
	

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
	
	last_collision_normal = normal
	
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
			if game.tiles.is_safe(tile_type) and tilemap.name.contains("gear") == false:
				var centre_safe_block = Vector2(coords.x * Settings.tile_size_half.x * 2 + Settings.tile_size_half.x, coords.y * Settings.tile_size_half.y * 2 + Settings.tile_size_half.y).rotated(tilemap.global_rotation)
				last_safe_position = centre_safe_block - (Vector2(0,(1 * Settings.tile_size.y) - 22)).rotated(tilemap.global_rotation + rotation)
				var layers = tilemap.get_node("../../")
				last_safe_layer = layers.get_node(str(str(tilemap.get_parent().name)))
	
	# blow up tiles when sun lightbreaking
	if lightbreak_direction.length() > 0 && lightbreak_fire_power > 0:
		TileEffects.shatter(tilemap, coords)
		lightbreak_fire_power -= 1
		return false
	else:
		return true


func set_depth(depth: int) -> void:
	var solid_layer = Helpers.to_bitmask_32((depth * 2) - 1)
	var vapor_layer = Helpers.to_bitmask_32(depth * 2)
	collision_layer = solid_layer
	collision_mask = solid_layer
	low_area.collision_layer = vapor_layer
	low_area.collision_mask = solid_layer | vapor_layer
	high_area.collision_mask = solid_layer


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


func update_animation() -> void:
	# face left or right
	control_vector = Input.get_vector("left", "right", "up", "down")
	if control_vector.x > 0:
		display.scale.x = 1
	if control_vector.x < 0:
		display.scale.x = -1
	
	# crouching
	if is_crouching:
		animations.play("crawl")
		
	# on ground
	elif is_on_floor():
		if super_jump.is_charging():
			animations.play("charge")
		elif control_vector.x != 0:
			animations.play("run")
		else:
			animations.play("idle")
			
	# in the air
	else:
		animations.play("jump")
	
	# super jump charge effect
	if super_jump.is_fully_charged():
		display.scale.y = randf_range(0.9, 1.1)
		if display.scale.x > 0:
			display.scale.x = randf_range(0.9, 1.7)
		else:
			display.scale.x = -randf_range(0.9, 1.7)
		display.modulate = Color("FFFF00")
	elif super_jump.is_locking():
		display.scale.y = randf_range(0.8, 1.1)
		display.modulate = Color("FFFFAA")
	else:
		display.modulate = Color("FFFFFF")
		display.scale.y = 1
		if display.scale.x > 0:
			display.scale.x = 1
		else:
			display.scale.x = -1
