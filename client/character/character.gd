class_name Character
extends CharacterBody2D
## Main player character with physics, items, and movement controls
##
## Handles all character physics, movement, animation, 
## item management and interaction with game tiles.

signal position_changed(x: float, y: float)
signal increase_time(new_timer: float)

@onready var hitbox := $CharacterHitbox
@onready var light := $Light
@onready var camera := $Camera
@onready var sun_particles := $SunParticles
@onready var moon_particles := $MoonParticles
@onready var speed_particles := $SpeedParticles
@onready var low_area := $LowArea
@onready var high_area := $HighArea
@onready var item_manager := $ItemManager
@onready var ice := $Ice
@onready var invincibility := $Invincibility
@onready var display := $Display
@onready var item_holder_display := $Display/ItemHolder
@onready var sjaura := $SuperJumpAura
@onready var animations: AnimationPlayer = $Display/Animations

var active := false
var item: Node2D
var game: Node2D
var shielded: bool = false
var tiles: Tiles

# Component controllers
var stats: Stats = Stats.new()
var gravity: Gravity = Gravity.new()
var super_jump: SuperJump = SuperJump.new()
var camera_controller: CameraController
var lightbreak: LightbreakController
var movement: MovementController
var animation: AnimationController
var tile_interaction: TileInteractionController
var control_vector: Vector2


func _ready() -> void:
	item_manager.init(self)
	item_manager.item_holder = item_holder_display
	# Initialize all the controllers
	camera_controller = CameraController.new(camera)
	lightbreak = LightbreakController.new(light, sun_particles, moon_particles)
	movement = MovementController.new(ice)
	animation = AnimationController.new(display, sjaura)
	

func init(tiles_node: Tiles) -> void:
	tiles = tiles_node
	tile_interaction = TileInteractionController.new(tiles, low_area, high_area)
	tile_interaction.last_safe_position = Vector2(position)


func _physics_process(delta: float) -> void:
	if not active or not tile_interaction:
		return
	
	# Update hitbox based on crouch state and size
	movement.is_crouching = tile_interaction.should_crouch(self)
	hitbox.run(self)
	low_area.scale = movement.size
	high_area.scale = movement.size
	display.item_holder.scale = display.scale / movement.size
	
	# Process gravity
	gravity.run(self, delta)
	
	# Update velocity from super jump
	if not movement.hurt and gravity.not_rotating(delta):
		super_jump.run(self, delta)
	
	# Process item forces
	_process_item_forces(delta)
	
	# Process movement
	velocity = movement.process(delta, self, stats, gravity, super_jump)
	
	# Process lightbreak
	control_vector = Input.get_vector("left", "right", "up", "down")
	var lightbreak_velocity := lightbreak.process(delta, control_vector, self)
	if lightbreak_velocity != Vector2.ZERO:
		velocity = lightbreak_velocity
	
	if gravity.not_rotating(delta):
		movement.previous_velocity = velocity
		if !movement.finished:
			move_and_slide()
	
	# Interact with tiles
	tile_interaction.interact_with_incoporeal_tiles(self)
	var hit_something := tile_interaction.interact_with_solid_tiles(self, lightbreak)
	
	# End lightbreak if we hit something
	if hit_something and lightbreak.direction.length() > 0:
		lightbreak.end_lightbreak()
	
	# Item usage
	if !movement.finished:
		_process_items(delta)
	
	# Update camera
	camera_controller.process(delta, position, rotation, lightbreak.is_active())
	
	# Update animations
	scale = movement.size
	animation.process(self, movement, super_jump)
	
	# Check boundaries
	tile_interaction.check_out_of_bounds(self)


func _bump_tile_covering_high_area() -> void:
	var tiles: Array = get_tiles_overlapping_area(high_area)
	
	if tiles.size() != 0:
		var tile = tiles[0]
		var tile_type = CoordinateUtils.to_block_id(tile.atlas_coords)
	
		movement.attempting_bump = true
		if tile != movement.last_bumped_block:
			tile_interaction._tiles.on("bottom", tile_type, self, tile.tile_map_layer, tile.coords)
			tile_interaction._tiles.on("any_side", tile_type, self, tile.tile_map_layer, tile.coords)
			tile_interaction._tiles.on("bump", tile_type, self, tile.tile_map_layer, tile.coords)
			movement.last_bumped_block = tile
			Jukebox.play_sound("bump")
	else:
		push_error("TileInteractionController::bump_tile_covering_high_area - No tile covering high area")


func _process_item_forces(delta: float) -> void:
	var item_force := Vector2.ZERO
	if item_manager.item:
		item_force = item_manager.force
	
	if item_force != Vector2.ZERO:
		var item_force_x: float = item_force.x * display.scale.x
		var item_force_y := item_force.y
		velocity += Vector2(item_force_x, item_force_y).rotated(rotation)


func _process_items(delta: float) -> void:
	# Use items
	if not movement.hurt and Input.is_action_pressed("item"):
		item_manager.try_to_use(delta)
	
	# Check item state
	if not movement.hurt and item:
		item_manager.check_item(delta)


# Public methods maintained for compatibility with existing code

func freeze() -> void:
	movement.freeze(stats.get_skill_bonus())


func hitstun(base_hitstun_time: float) -> void:
	movement.hitstun((base_hitstun_time * 2) / stats.get_skill_bonus(), shielded)


func is_in_solid() -> bool:
	return tile_interaction.is_in_solid(self)


func end_lightbreak() -> void:
	lightbreak.end_lightbreak()
	modulate.a = 1


func set_depth(depth: int) -> void:
	tile_interaction.set_depth(self, depth)


func set_item(new_item_id: int) -> void:
	item_manager.set_item_id(new_item_id)


func get_tiles_overlapping_area(area: Area2D) -> Array:
	return tile_interaction.get_tiles_overlapping_area(area)
