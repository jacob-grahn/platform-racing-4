extends Node2D
class_name SliderRow

var step_delay = 0.1


func add_slider(slider: Node2D) -> void:
	slider.position = Vector2(get_dimensions().x, 0)
	add_child(slider)
	slider.appear(step_delay * get_child_count())


func disappear() -> void:
	var delay = 0
	for slider in get_children():
		slider.disappear(delay)
		delay += step_delay


func get_dimensions() -> Vector2:
	var dimensions = Vector2(0, 0)
	for slider in get_children():
		var slider_dimensions = slider.get_dimensions()
		dimensions.y = max(dimensions.y, slider_dimensions.y)
		dimensions.x += slider_dimensions.x
	return dimensions
