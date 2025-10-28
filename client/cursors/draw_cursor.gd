extends Node2D

signal level_event

var current_line: Line2D
var current_point: Vector2i
var optimization_epsilon: float = 1.0 # bigger = more line optimization
var layers: Layers
var brush_size: float = 3.0
var brush_color: Color = Color(0, 0, 0) # Default to black


func init(_layers: Layers) -> void:
	layers = _layers


func on_mouse_down():
	print("DrawCursor::on_mouse_down")
	if !current_line:
		var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
		var lines: Node2D = layer.get_node("Lines")
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = lines.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
		current_line = Line2D.new()
		lines.add_child(current_line)
		current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
		current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		current_line.width = brush_size
		current_line.default_color = brush_color
		current_line.position = mouse_position.round()
		current_line.add_point(Vector2i(0, 0))
		current_point = Vector2i(0, 0)


func on_drag():
	if current_line:
		var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
		var lines: Node2D = layer.get_node("Lines")
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = lines.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
		var point = Vector2i((mouse_position - current_line.position).round())
		if point != current_point:
			current_line.add_point(point)
			current_point = point


func on_mouse_up():
	if current_line:
		
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
			"layer_name": layers.get_target_layer(),
			"position": {
				"x": current_line.position.x,
				"y": current_line.position.y
			},
			"points": point_dicts,
			"width": brush_size,
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


func set_brush_size(size: float) -> void:
	brush_size = size


func set_brush_color(color: Color) -> void:
	brush_color = color
