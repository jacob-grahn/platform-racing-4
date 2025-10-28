extends Node2D

signal level_event

@onready var haircross = $Haircross
@onready var brush_circle = $BrushCircle
var active: bool = false
var current_line: Line2D
var current_point: Vector2i
var optimization_epsilon: float = 1.0 # bigger = more line optimization
var layers: Layers
var mode: String = "draw"
var brush_size: float = 5.0
var size_multiplier: float = 2
var brush_color: Color = Color(0, 0, 0) # Default to black
var brush_alpha: float = 100.0


func _ready() -> void:
	pass


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		haircross.visible = false
		brush_circle.visible = false
		var touching_gui: bool = get_parent().touching_gui
		if touching_gui:
			haircross.visible = true
			brush_circle.visible = true
			brush_circle.set_brush_circle(brush_size, size_multiplier)
	else:
		visible = false


func init(_menu, _layers) -> void:
	layers = _layers
	_menu.connect("control_event", _on_control_event)


func _on_control_event(event: Dictionary) -> void:
	print("DrawCursor::_on_control_event", event)
	if event.type == EditorEvents.SELECT_ART_MODE:
		mode = event.mode


func on_mouse_down():
	if active:
		if mode == "draw" and !current_line:
			print("DrawCursor::on_mouse_down")
			var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
			var lines: Node2D = layer.get_node("Lines")
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = lines.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
			current_line = Line2D.new()
			lines.add_child(current_line)
			current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.width = brush_size * size_multiplier
			current_line.default_color = brush_color
			current_line.self_modulate.a = brush_alpha
			current_line.position = mouse_position.round()
			current_line.add_point(Vector2i(0, 0))
			current_point = Vector2i(0, 0)


func on_drag():
	if active:
		if mode == "draw" and current_line:
			var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
			var lines: Node2D = layer.get_node("Lines")
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = lines.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
			var point = Vector2i((mouse_position - current_line.position).round())
			if point != current_point:
				current_line.add_point(point)
				current_point = point
		elif mode == "erase":
			erase_lines()


func on_mouse_up():
	if active:
		if mode == "draw" and current_line:
			
			# Just clicks with no drag should produce a dot
			if len(current_line.points) == 1:
				current_line.add_point(Vector2i(1, 1))
		
			# Simplify the line
			var simplified_points = douglas_peucker(current_line.points, optimization_epsilon)
		
			var point_dicts = []
			for point in simplified_points:
				point_dicts.append({"x": point.x, "y": point.y})

			emit_signal("level_event", {
				"type": EditorEvents.ADD_LINE,
				"layer_name": layers.get_target_art_layer(),
				"position": {
					"x": current_line.position.x,
					"y": current_line.position.y
				},
				"points": point_dicts,
				"width": brush_size * size_multiplier,
				"color": brush_color.to_html(true) # Include alpha in hex format (e.g. FFFFFFFF)
			})
		
			# Remove the temporary line
			current_line.queue_free()


# Function to calculate the perpendicular distance from a point to a line formed by two points
func perpendicular_distance(point, line_start, line_end):
	if line_start == line_end:
		return (line_start - point).length()
	else:
		var n = abs((line_end.x - line_start.x) * (line_start.y - point.y) - (line_start.x - point.x) * (line_end.y - line_start.y))
		var d = (line_end - line_start).length()
		return n / d


# Recursive function implementing the Douglas-Peucker algorithm
func douglas_peucker(points, epsilon):
	# Find the point with the maximum distance from line between the start and end
	var max_distance = 0
	var index = 0
	for i in range(1, points.size() - 1):
		var dist = perpendicular_distance(points[i], points[0], points[-1])
		if dist > max_distance:
			index = i
			max_distance = dist
	
	# If max distance is greater than epsilon, recursively simplify
	if max_distance > epsilon:
		# Recursive call
		var rec_results1 = douglas_peucker(points.slice(0, index + 1), epsilon)
		var rec_results2 = douglas_peucker(points.slice(index), epsilon)
		
		# Build the result list
		var result = rec_results1 + rec_results2.slice(1)
		return result
	else:
		# None are far enough to keep any point except the endpoints
		return [points[0], points[-1]]


func erase_lines():
	var radius: float = (brush_size * size_multiplier) / 2
	var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
	var line_holder: Node2D = layer.get_node("Lines")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = line_holder.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	for line in line_holder.get_children():
		var points = line.points
		for i in range(points.size() - 1):
			var p1: Vector2 = points[i] + line.position
			var p2: Vector2 = points[i + 1] + line.position
			
			# Check if the line segment p1-p2 intersects the circle
			if is_line_intersecting_circle(p1, p2, mouse_position, radius):
				line.queue_free()
				break # Break since the line should be removed


# Helper function to check if a line segment intersects a circle
func is_line_intersecting_circle(p1: Vector2, p2: Vector2, circle_center: Vector2, radius: float) -> bool:
	var segment_vector: Vector2 = p2 - p1
	var to_circle: Vector2 = circle_center - p1
	var segment_length: float = segment_vector.length()

	# Project the circle's center onto the line segment
	var projection_length: float = segment_vector.dot(to_circle) / segment_length
	var projection_point: Vector2 = p1 + (segment_vector.normalized() * projection_length)

	# Clamp the projection to lie on the segment
	var clamped_projection: Vector2 = projection_point.clamp(p1, p2)

	# Check the distance from the closest point on the segment to the circle's center
	var distance_to_circle: float = clamped_projection.distance_to(circle_center)

	return distance_to_circle <= radius


func set_brush_size(size: int) -> void:
	brush_size = size


func set_brush_color(color: Color) -> void:
	brush_color = color


func set_brush_alpha(alpha: float) -> void:
	brush_alpha = alpha
