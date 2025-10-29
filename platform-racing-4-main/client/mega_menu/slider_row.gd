extends Node2D
class_name SliderRow

var step_delay: float = 0.1
var max_width: float = 100
var pos: Vector2i = Vector2i(0, 0)
var default_slider_dimensions = Vector2i(64, 64)


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func add_slider(slider: Node) -> void:
	if slider.has_signal("control_event"):
		slider.control_event.connect(_on_control_event)
	add_child(slider)
	_position_slider(slider)


func get_dimensions() -> Vector2:
	var dimensions = Vector2(0, 0)
	for slider in get_children():
		var slider_dimensions: Vector2 = _get_slider_dimensions(slider)
		dimensions.y = max(dimensions.y, (slider.position.y + slider_dimensions.y))
		dimensions.x = max(dimensions.x, (slider.position.x + slider_dimensions.x))
	return dimensions


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	max_width = window_size.x
	_position_sliders()


func _position_sliders():
	pos = Vector2i(0, 0)
	for slider in get_children():
		_position_slider(slider)


func _get_slider_dimensions(slider: Node) -> Vector2:
	if slider.has_method('get_dimensions'):
		return slider.get_dimensions()
	else:
		return default_slider_dimensions


func _position_slider(slider: Node):
	var slider_dimensions: Vector2 = _get_slider_dimensions(slider)
	if pos.x + slider_dimensions.x > max_width:
		pos.x = 0
		pos.y += slider_dimensions.y
	slider.position = pos
	pos.x += slider_dimensions.x


func _on_control_event(event) -> void:
	emit_signal("control_event", event)
