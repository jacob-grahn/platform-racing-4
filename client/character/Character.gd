extends CharacterBody2D
class_name Character

const SPEED = 490.0
const JUMP_VELOCITY = Vector2(0, -155.0)
const FASTFALL_VELOCITY = Vector2(0, 50.0)
const MAX_VELOCITY = Vector2(4500.0, 3750.0)
const SWIM_UP_VELOCITY = Vector2(0, -SPEED * 7)
const TRACTION = 4000
const FRICTION = 0.1
const FRICTION_SWIMMING = 2
const LIGHTBREAK_SPEED = 200000.0
const JUMP_VELOCITY_MULTIPLIER = 0.75
const JUMP_TIMER_MAX = 10.0
const OUT_OF_BOUNDS_BLOCK_COUNT = 10
const LightLine2D = preload("res://tiles/lights/light_line_2d.tscn")

@onready var hitbox = $CharacterHitbox
@onready var light = $Light
@onready var camera = $Camera
@onready var sun_particles = $SunParticles
@onready var moon_particles = $MoonParticles
@onready var speed_particles = $SpeedParticles
@onready var low_area = $LowArea
@onready var high_area = $HighArea
@onready var item_manager = $ItemManager
@onready var ice = $Ice
@onready var invincibility = $Invincibility
@onready var display = $Display
@onready var sjaura = $SuperJumpAura
@onready var animations: AnimationPlayer = $Display/Animations

var active = false
var control_vector: Vector2
var jump_timer: float = 0
var facing: int = 1
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
var shake: float = 0.0
var sjanim: float = 0.0
var item_force: = Vector2(0, 0)
var shielded: bool = false
var hitstun_duration: float = 0.0
var hitstun_timer: float = 0.0
var hurt: bool = false
var frozen: bool = false
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
var camera_pos: Vector2 = Vector2(0,0)
var camera_pos_smoothing: float = 0.333 # lower values take longer for camera to adjust to player position. 0 takes infinite amount of time, 1 adjusts instantly.

# Use this to apply a longer velocity shift
var phantom_velocity: Vector2 = Vector2(0 , 0)
var phantom_velocity_decay: float = 0.25

signal position_changed(x: float, y: float)

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
	if frozen and frozen_timer >= 0:
		frozen_timer -= delta
		ice.visible = true
		ice.modulate.a = ((1 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
		ice.scale.y = ((0.65 / (3.0 / stats.get_skill_bonus())) * frozen_timer)
		display.modulate = Color(1.0 - (ice.modulate.a / 2), 1.0, 1.0)
		traction = TRACTION / 10.0
	else:
		ice.visible = false
		frozen = false
	
	if hurt:
		if hitstun_timer > 0:
			hitstun_timer -= delta
		else:
			hurt = false
	
	# Gravity
	gravity.run(self, delta)
	
	# Checks if player is rotating
	var not_rotating: bool = gravity.not_rotating(delta)
	
	# Inputs
	var control_axis: float = Input.get_axis("left", "right")
	if !hurt and control_axis < 0:
		facing = -1
	elif !hurt and control_axis > 0:
		facing = 1

	# Super jump
	if !hurt and not_rotating:
		super_jump.run(self, delta)
	
	# Checks if the item the player is holding is pushing them somewhere
	if item_manager.item:
		item_force = item_manager.get_item_force(delta)
	else:
		item_force = Vector2(0, 0)
	var item_force_x = item_force.x * display.scale.x
	var item_force_y = item_force.y
	if item_force != Vector2(0, 0):
		velocity += Vector2(item_force_x, item_force_y).rotated(rotation)
	
	# Handle jump.
	if !hurt and can_jump and Input.is_action_pressed("jump"):
		
		if is_crouching:
			_bump_tile_covering_high_area()
		
		elif is_on_floor() and velocity.rotated(-rotation).y > JUMP_VELOCITY.y * JUMP_VELOCITY_MULTIPLIER:
			jumped = true
			jump_timer = JUMP_TIMER_MAX
	
	# Handle jump strength/velocity increment
	if not_rotating and jumped:
		velocity += JUMP_VELOCITY.rotated(rotation) * stats.get_jump_bonus() * (jump_timer / JUMP_TIMER_MAX)
		jump_timer -= 1
		if jump_timer <= 0:
			jumped = false
			jump_timer = 0
			
	# Caps speed velocity and falling velocity so things don't get too crazy.
	if abs(velocity.x) > MAX_VELOCITY.x:
		if velocity.x > 0:
			velocity.x = MAX_VELOCITY.x
		else:
			velocity.x = MAX_VELOCITY.x * -1
	if abs(velocity.y) > MAX_VELOCITY.y:
		if velocity.y > 0:
			velocity.y = MAX_VELOCITY.y
		else:
			velocity.y = MAX_VELOCITY.y * -1
		
	# Airborne behavior
	if not_rotating and not is_on_floor():
		# Cancel jump early by not pressing jump.
		if jumped and not Input.is_action_pressed("jump"):
			jumped = false
		# Fastfall; if down pressed while not on floor, fall faster
		if !hurt and Input.is_action_pressed("down"):
			if swimming:
				velocity += (FASTFALL_VELOCITY / 2).rotated(rotation)
			else:
				velocity += FASTFALL_VELOCITY.rotated(rotation)
		# if in liquid, we can swim up
		if !hurt and swimming && Input.is_action_pressed("up"):
			velocity += SWIM_UP_VELOCITY.rotated(rotation) * delta
		# extra jump is gone after releasing jump button
		if not jumped:
			jump_timer = 0
	
	# Move left/right
	if not_rotating:
		if hurt or super_jump.is_locking():
			control_axis = 0
		if !hurt and is_crouching:
			control_axis = control_axis / 2
		var target_velocity = Vector2(control_axis * SPEED * stats.get_speed_bonus(), velocity.rotated(-rotation).y).rotated(rotation)
		var accel = 0.8 * (stats.get_accel_bonus() / 1.5)
		if control_axis != 0:
			if target_velocity.length() > velocity.length():
				traction *= accel
			velocity = velocity.move_toward(target_velocity, delta * traction)
		else:
			velocity = velocity.move_toward(target_velocity, delta * traction * accel)
	
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
	if not_rotating:
		previous_velocity = velocity
		move_and_slide()
	
	# interact with tiles
	interact_with_incoporeal_tiles()
	var hit_something = interact_with_solid_tiles()
	
	# end lightbreak if you hit a wall
	if hit_something && lightbreak_direction.length() > 0:
		end_lightbreak()
	
	# Use items
	if !hurt and Input.is_action_pressed("item"):
		item_manager.use(delta)
	
	# checks if an item has run out of ammo or has been used.
	if !hurt and item:
		item_manager.check_item(delta)

	# camera position smoothing
	var actual_Weight = 1-pow(1-camera_pos_smoothing,delta*30); # I know 30 is a magic number but idk what else to do with it
	camera_pos = lerp(camera_pos,position,actual_Weight)
	camera.offset.x = camera_pos.x - position.x
	camera.offset.y = camera_pos.y - position.y
	
	# Save velocity for a cycle
	last_velocity = Vector2(velocity)
	
	# Look good
	update_animation()
	check_out_of_bounds()
	
	Session.set_player_position(position)


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
	frozen = true
	frozen_timer = 3.0 / stats.get_skill_bonus()


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

# Stuns the player when they hit a mine
func hitstun(hitstun: float):
	if !shielded and !hurt:
		hitstun_duration = hitstun
		hitstun_timer = hitstun
		frozen_timer = 0
		frozen = false
		hurt = true

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

func set_item(new_item_id: int) -> void:
	var item_id = new_item_id
	item_manager.set_item_id(item_id)

func update_animation() -> void:
	# face left or right
	control_vector = Input.get_vector("left", "right", "up", "down")
	if !hurt:
		display.scale.x = facing
	else:
		if (hitstun_duration - hitstun_timer) < 0.4:
			display.play(CharacterDisplay.HURT_START)
		elif hitstun_timer > 0.5:
			display.play(CharacterDisplay.HURT)
		else:
			display.play(CharacterDisplay.RECOVER)
			
	if frozen:
		display.set_speed_scale(1 - ice.modulate.a)
	elif super_jump.is_locking() and super_jump.charge_precentage() < 1:
		display.set_speed_scale(1 / super_jump.CHARGE_TIMER_MAX)
	else:
		display.set_speed_scale(1)
	
	# crouching
	if !hurt and is_crouching:
		if control_vector.x != 0:
			display.play(CharacterDisplay.CRAWL)
		else:
			display.play(CharacterDisplay.CROUCH)
		
	# on ground
	elif !hurt and is_on_floor():
		if super_jump.is_locking():
			if super_jump.charge_precentage() < 1:
				display.play(CharacterDisplay.CHARGE)
			else:
				display.play(CharacterDisplay.CHARGE_HOLD)
		elif control_vector.x != 0:
			display.play(CharacterDisplay.RUN)
		else:
			display.play(CharacterDisplay.IDLE)
			
	# in the air
	elif !hurt and swimming:
		display.play(CharacterDisplay.SWIM)
	elif !hurt:
		display.play(CharacterDisplay.JUMP)
	
	# super jump charge effect
	shake = super_jump.charge_precentage() / 8
	sjanim = randf_range(1 - shake, 1 + shake)
	if super_jump.is_locking():
		display.scale.y = sjanim
		if !frozen:
			display.modulate.b = 1.0 - super_jump.charge_precentage()
		sjaura.modulate.a = super_jump.charge_precentage() / 2
		sjaura.scale.y = super_jump.charge_precentage() / 2
		if !sjaura.visible:
			sjaura.visible = true
	else:
		if sjaura.visible:
			sjaura.visible = false
		if !frozen:
			display.modulate = Color(1.0, 1.0, 1.0)
		display.scale.y = 1
		display.scale.x = facing
		shake = 0

func check_out_of_bounds() -> void:
	var map_used_rect = Session.get_used_rect()
	
	var min_x = map_used_rect.position.x - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_x = map_used_rect.position.x + map_used_rect.size.x + OUT_OF_BOUNDS_BLOCK_COUNT
	var min_y = map_used_rect.position.y - OUT_OF_BOUNDS_BLOCK_COUNT
	var max_y = map_used_rect.position.y + map_used_rect.size.y + OUT_OF_BOUNDS_BLOCK_COUNT
	
	var player_x_normalised = position.x / Settings.tile_size.x
	var player_y_normalised = position.y / Settings.tile_size.y
		
	if player_x_normalised < min_x or player_x_normalised > max_x or \
	   player_y_normalised < min_y or player_y_normalised > max_y:
		position.x = last_safe_position.x
		position.y = last_safe_position.y
		velocity = Vector2(0, 0)
		
