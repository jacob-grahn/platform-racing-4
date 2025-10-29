class_name LightbreakController
## Manages the character's lightbreak ability.
## Controls different light types (firefly, sun, moon) and their effects.

const LIGHTBREAK_SPEED = 200000.0
const LightLine2D = preload("res://tiles/lights/light_line_2d.tscn")

var direction: Vector2 = Vector2(0, 0)
var windup: float = 0
var input_primed: bool = false
var src_tile: Vector2i
var type: String = ""
var line: Node2D
var fire_power: int = 0
var moon_timer: float = 0

var sun_particles: GPUParticles2D
var moon_particles: GPUParticles2D
var light: PointLight2D


func _init(player_light: PointLight2D, player_sun_particles: GPUParticles2D, player_moon_particles: GPUParticles2D):
	light = player_light
	sun_particles = player_sun_particles
	moon_particles = player_moon_particles


func process(delta: float, control_vector: Vector2, player: Character) -> Vector2:
	var velocity_change = Vector2(0, 0)
	
	# Lightbreak cooldown
	if windup > 0:
		windup -= delta
		if windup <= 0:
			src_tile = Vector2i(0, 0)
			input_primed = false
	
	# Manage character light
	if windup > 0 or direction.length() > 0:
		light.enabled = true
		if direction.length() > 0:
			light.energy = 0.5
		else:
			light.energy = windup / 2
	else:
		light.enabled = false
	
	# Active lightbreak
	if direction.length() > 0:
		velocity_change = direction * LIGHTBREAK_SPEED * delta
		if (control_vector + direction).length() < 0.5:
			end_lightbreak()
	
	# Firefly type handling
	if type == LightTile.FIREFLY:
		if direction.length() > 0:
			if !line:
				line = LightLine2D.instantiate()
				player.get_parent().add_child(line)
			line.add_point(player.position)
		if control_vector.length() > 0:
			if (control_vector + direction).length() > 0.5:
				direction = control_vector
	
	# Sun type handling
	if type == LightTile.SUN:
		if direction.length() > 0:
			sun_particles.emitting = true
	
	# Moon type handling
	if type == LightTile.MOON and direction.length() > 0:
		player.modulate.a = randf_range(0, 0.66)
		moon_timer -= delta
		moon_particles.emitting = true
		if moon_timer < 0 and !player.is_in_solid():
			end_lightbreak()
	
	return velocity_change


func end_lightbreak():
	direction = Vector2(0, 0)
	type = ""
	line = null
	fire_power = 0
	sun_particles.emitting = false
	
	# These might be better handled by the main character class
	# but keeping them here for now
	moon_particles.emitting = false
	moon_timer = 0


func is_active() -> bool:
	return windup > 0 or direction.length() > 0
