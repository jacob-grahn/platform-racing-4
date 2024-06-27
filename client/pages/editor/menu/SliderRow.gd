extends Node2D
class_name SliderRow

var step_delay: float = 0.1
var max_width: float = 100
var slider_dimensions: Vector2 = Vector2(0, 0)
var pos: Vector2i = Vector2i(0, 0)


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func add_slider(slider: Node2D) -> void:
	add_child(slider)
	slider_dimensions = slider.get_dimensions()
	slider.appear(step_delay * get_child_count())
	position_slider(slider)


func disappear() -> void:
	var delay = 0
	for slider in get_children():
		slider.disappear(delay)
		delay += step_delay


func get_dimensions() -> Vector2:
	var dimensions = Vector2(0, 0)
	for slider in get_children():
		var slider_dimensions = slider.get_dimensions()
		dimensions.y = max(dimensions.y, (slider.position.y + slider_dimensions.y))
		dimensions.x = max(dimensions.x, (slider.position.x + slider_dimensions.x))
	return dimensions


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	max_width = window_size.x
	position_sliders()


func position_sliders():
	pos = Vector2i(0, 0)
	for slider in get_children():
		position_slider(slider)


func position_slider(slider: Node2D):
	var slider_dimensions = slider.get_dimensions()
	if pos.x + slider_dimensions.x > max_width:
		pos.x = 0
		pos.y += slider_dimensions.y
	slider.position = pos
	pos.x += slider_dimensions.x
