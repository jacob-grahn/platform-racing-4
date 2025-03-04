class_name Character
extends CharacterBody2D
## Main player character with physics, items, and movement controls
##
## Handles all character physics, movement, animation, 
## item management and interaction with game tiles.

signal position_changed(x: float, y: float)

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
@onready var sjaura := $SuperJumpAura
@onready var animations: AnimationPlayer = $Display/Animations

var active := false
var item: Node2D
var game: Node2D
var shielded: bool = false

# Component controllers
var stats: Stats = Stats.new()
var gravity: Gravity = Gravity.new()
var super_jump: SuperJump = SuperJump.new()
var camera_controller: CameraController
var lightbreak: LightbreakController
var movement: MovementController
var animation: AnimationController
var tile_interaction: TileInteractionController


func _ready() -> void:
	game = get_parent().get_parent().get_parent().get_parent()
	
	# Initialize all the controllers
	camera_controller = CameraController.new(camera)
	lightbreak = LightbreakController.new(light, sun_particles, moon_particles)
	movement = MovementController.new(ice)
	animation = AnimationController.new(display, sjaura)
	tile_interaction = TileInteractionController.new(game, low_area, high_area)
	
	tile_interaction.last_safe_position = Vector2(position)


func _physics_process(delta: float) -> void:
	if not active:
		return
	
	# Update hitbox based on crouch state
	movement.is_crouching = tile_interaction.should_crouch(self)
	hitbox.run(self)
	
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
	var control_vector := Input.get_vector("left", "right", "up", "down")
	var lightbreak_velocity := lightbreak.process(delta, control_vector, self)
	if lightbreak_velocity != Vector2.ZERO:
		velocity = lightbreak_velocity
	
	# Move the character if we're not rotating
	if gravity.not_rotating(delta):
		movement.previous_velocity = velocity
		move_and_slide()
	
	# Interact with tiles
	tile_interaction.interact_with_incoporeal_tiles(self)
	var hit_something := tile_interaction.interact_with_solid_tiles(self, lightbreak)
	
	# End lightbreak if we hit something
	if hit_something and lightbreak.direction.length() > 0:
		lightbreak.end_lightbreak()
	
	# Item usage
	_process_items(delta)
	
	# Update camera
	camera_controller.process(delta, position, lightbreak.is_active())
	
	# Update animations
	animation.process(self, movement, super_jump)
	
	# Check boundaries
	tile_interaction.check_out_of_bounds(self)
	
	# Update session
	Session.set_player_position(position)


func _process_item_forces(delta: float) -> void:
	var item_force := Vector2.ZERO
	if item_manager.item:
		item_force = item_manager.get_item_force(delta)
	
	if item_force != Vector2.ZERO:
		var item_force_x: float = item_force.x * display.scale.x
		var item_force_y := item_force.y
		velocity += Vector2(item_force_x, item_force_y).rotated(rotation)


func _process_items(delta: float) -> void:
	# Use items
	if not movement.hurt and Input.is_action_pressed("item"):
		item_manager.use(delta)
	
	# Check item state
	if not movement.hurt and item:
		item_manager.check_item(delta)


# Public methods maintained for compatibility with existing code

func _bump_tile_covering_high_area() -> void:
	tile_interaction.bump_tile_covering_high_area(self)


func freeze() -> void:
	movement.freeze(stats.get_skill_bonus())


func hitstun(hitstun_time: float) -> void:
	movement.hitstun(hitstun_time, shielded)


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
