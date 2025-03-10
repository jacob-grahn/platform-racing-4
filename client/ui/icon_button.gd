extends Node2D
class_name IconButton

const dimensions = Vector2(64, 64)
var active = false
var active_colors = {
	"bg": Color("000000"),
	"icon": Color("FFFFFF")
}
var inactive_colors = {
	"bg": Color("FFFFFF"),
	"icon": Color("000000")
}

@onready var texture_button: TextureButton = $TextureButton
@onready var color_rect: ColorRect = $ColorRect
@onready var texture_rect: TextureRect = $TextureRect

# Sparks and trail effect properties
var spark1: Sprite2D
var spark2: Sprite2D
var spark_rotation_speed = 1.5
var sparks_initialized = false
var color1 = Color(1, 1, 0.3)  # Yellow-ish
var color2 = Color(0.3, 1, 1)   # Cyan-ish
var trail_points = []           # Store trail points with their sprites
var max_trail_points = 10       # Maximum number of trail points per spark
var trail_fade_time = 0.75      # Time in seconds for trail points to fade out
var trail_container: Node2D     # Container for all trail particles


func _ready() -> void:
	texture_button.pressed.connect(_pressed)
	_setup_trail_container()
	_setup_sparks()
	_setup_trails()
	# Initial render after sparks are set up
	_render()


func _setup_trail_container() -> void:
	# Create a container for all trail particles
	trail_container = Node2D.new()
	trail_container.name = "TrailContainer"
	trail_container.z_index = 4  # Just below sparks
	add_child(trail_container)


func _setup_sparks() -> void:
	# Create the first spark
	spark1 = Sprite2D.new()
	spark1.texture = preload("res://character/star_08.png")
	spark1.scale = Vector2(0.3, 0.3)
	spark1.visible = false
	spark1.z_index = 5
	spark1.modulate = color1
	add_child(spark1)
	
	# Create the second spark
	spark2 = Sprite2D.new()
	spark2.texture = preload("res://character/star_08.png")
	spark2.scale = Vector2(0.25, 0.25)
	spark2.visible = false
	spark2.z_index = 5
	spark2.modulate = color2
	add_child(spark2)
	
	sparks_initialized = true


func _setup_trails() -> void:
	# Initialize empty arrays for trail points
	trail_points = [[], []]  # One array for each spark


func init(texture: Texture2D, p_active_colors: Dictionary, p_inactive_colors: Dictionary) -> void:
	active_colors = p_active_colors.duplicate()
	inactive_colors = p_inactive_colors.duplicate()
	
	# Set the texture
	texture_rect.texture = texture
	_render()


func set_active(p_active: bool) -> void:
	active = p_active
	_render()
	
	# Update spark visibility only if they're initialized
	if sparks_initialized:
		spark1.visible = active
		spark2.visible = active
		set_process(active)
		
		# Clear trails when deactivating
		if not active:
			# Remove all trail sprites
			for spark_trails in trail_points:
				for trail_data in spark_trails:
					if is_instance_valid(trail_data.sprite):
						trail_data.sprite.queue_free()
			
			# Reset trail arrays
			trail_points = [[], []]


func get_dimensions() -> Vector2:
	return dimensions


func _pressed() -> void:
	set_active(!active)


func _process(delta: float) -> void:
	if active and sparks_initialized:
		_update_spark_positions(delta)
		_update_trails(delta)


func _update_spark_positions(delta: float) -> void:
	# Calculate parameters for spark movement
	var time = Time.get_ticks_msec() / 1000.0
	var normalized_pos1 = fmod(time * spark_rotation_speed, 4.0) / 4.0  # 0.0 to 1.0 range
	var normalized_pos2 = fmod(time * spark_rotation_speed + 2.0, 4.0) / 4.0  # Opposite side (0.5 cycle offset)
	
	# Calculate positions along the square perimeter
	var size = dimensions.x
	var margin = 0  # Distance from the edge
	var effective_size = size - 2 * margin  # Effective travel area size
	
	# Convert normalized position to square edge position
	spark1.position = _normalized_to_square_position(normalized_pos1, margin, effective_size)
	spark2.position = _normalized_to_square_position(normalized_pos2, margin, effective_size)
	
	# Add a pulsating effect
	var pulse = (sin(time * 3) + 1) / 4 + 0.75  # Pulse between 0.75 and 1.25 scale
	spark1.scale = Vector2(0.3, 0.3) * pulse
	spark2.scale = Vector2(0.25, 0.25) * pulse
	
	# Color transition effect
	var color_blend = (sin(time * 1.5) + 1) / 2  # 0 to 1 range for color lerp
	spark1.modulate = color1.lerp(color2, color_blend)
	spark2.modulate = color2.lerp(color1, color_blend)

	# Rotate sparks
	spark1.rotation = time * 2.0
	spark2.rotation = time * 2.0


func _update_trails(delta: float) -> void:
	if not sparks_initialized or not is_instance_valid(trail_container):
		return
	
	# Slow down trail creation based on delta
	# Only create a trail every few frames for better performance and visual effect
	if Engine.get_physics_frames() % 2 != 0:
		return
		
	var current_time = Time.get_ticks_msec() / 1000.0
	
	# Create a new trail particle for spark1
	var trail1 = Sprite2D.new()
	trail1.texture = spark1.texture
	trail1.position = spark1.position
	trail1.scale = spark1.scale * 0.8
	trail1.modulate = spark1.modulate
	trail1.modulate.a = 0.7  # Initial transparency
	trail1.rotation = spark1.rotation
	trail_container.add_child(trail1)
	
	# Create a new trail particle for spark2
	var trail2 = Sprite2D.new()
	trail2.texture = spark2.texture
	trail2.position = spark2.position
	trail2.scale = spark2.scale * 0.8
	trail2.modulate = spark2.modulate
	trail2.modulate.a = 0.7  # Initial transparency
	trail2.rotation = spark2.rotation
	trail_container.add_child(trail2)
	
	# Add to tracking arrays with creation time
	trail_points[0].append({
		"sprite": trail1,
		"creation_time": current_time
	})
	
	trail_points[1].append({
		"sprite": trail2,
		"creation_time": current_time
	})
	
	# Check existing trail particles and fade them out
	for i in range(trail_points[0].size() - 1, -1, -1):
		var trail_data = trail_points[0][i]
		var age = current_time - trail_data.creation_time
		
		if age > trail_fade_time:
			# Remove expired trail particles
			if is_instance_valid(trail_data.sprite):
				trail_data.sprite.queue_free()
			trail_points[0].remove_at(i)
		else:
			# Update fading trail particles
			if is_instance_valid(trail_data.sprite):
				var fade_factor = 1.0 - (age / trail_fade_time)
				trail_data.sprite.modulate.a = 0.7 * fade_factor
				trail_data.sprite.scale = spark1.scale * 0.8 * fade_factor
	
	# Do the same for spark2 trail
	for i in range(trail_points[1].size() - 1, -1, -1):
		var trail_data = trail_points[1][i]
		var age = current_time - trail_data.creation_time
		
		if age > trail_fade_time:
			# Remove expired trail particles
			if is_instance_valid(trail_data.sprite):
				trail_data.sprite.queue_free()
			trail_points[1].remove_at(i)
		else:
			# Update fading trail particles
			if is_instance_valid(trail_data.sprite):
				var fade_factor = 1.0 - (age / trail_fade_time)
				trail_data.sprite.modulate.a = 0.7 * fade_factor
				trail_data.sprite.scale = spark2.scale * 0.8 * fade_factor
	
	# Limit the number of trail particles for performance
	while trail_points[0].size() > max_trail_points:
		var trail_data = trail_points[0][0]
		if is_instance_valid(trail_data.sprite):
			trail_data.sprite.queue_free()
		trail_points[0].pop_front()
		
	while trail_points[1].size() > max_trail_points:
		var trail_data = trail_points[1][0]
		if is_instance_valid(trail_data.sprite):
			trail_data.sprite.queue_free()
		trail_points[1].pop_front()


# Maps a normalized position (0-1) to a point on a square path
func _normalized_to_square_position(t: float, margin: float, size: float) -> Vector2:
	# Determine which edge of the square (0-3)
	var edge = int(t * 4.0)
	var edge_t = fmod(t * 4.0, 1.0)  # Position along the edge (0-1)
	
	match edge:
		0:  # Top edge (left to right)
			return Vector2(margin + edge_t * size, margin)
		1:  # Right edge (top to bottom)
			return Vector2(margin + size, margin + edge_t * size)
		2:  # Bottom edge (right to left)
			return Vector2(margin + size - edge_t * size, margin + size)
		3:  # Left edge (bottom to top)
			return Vector2(margin, margin + size - edge_t * size)
		_:  # Fallback (shouldn't happen)
			return Vector2(margin, margin)


func _render() -> void:
	var colors = inactive_colors
	if active:
		colors = active_colors
	
	color_rect.color = colors.bg
	texture_rect.modulate = colors.icon
	
	# Show/hide sparks based on active state, but only if they're initialized
	if sparks_initialized:
		spark1.visible = active
		spark2.visible = active
		set_process(active)
	
	# Update texture scale if texture exists
	if texture_rect.texture != null:
		var texture_size_actual = texture_rect.texture.get_size()
		texture_rect.scale = Vector2(dimensions.x / texture_size_actual.x, dimensions.y / texture_size_actual.y)
