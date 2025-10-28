extends Control

signal set_new_slider_value

@onready var slider_line_edit = $SliderLineEdit
@onready var ok_button = $OKButton
@onready var slider = $Slider
var slider_value: int = 10
var old_size_box_text: String = "0"


func _ready() -> void:
	slider_line_edit.text_changed.connect(_set_size_value)
	ok_button.pressed.connect(_set_new_size_value)
	slider.value_changed.connect(_set_size_value)
	slider_line_edit.text = str(slider_value)
	slider.value = slider_value


func init(current_value: int, min_value: int, max_value: int):
	slider.min_value = min_value
	slider.max_value = max_value
	_set_size_value(current_value)


func _set_size_value(new_size):
	var compatible_new_size = int(new_size)
	var new_size_string = str(compatible_new_size)
	var min = int(slider.min_value)
	var max = int(slider.max_value)
	var cursor_position = slider_line_edit.get_caret_column()
	if !new_size_string.is_empty() and new_size_string.is_valid_int():
		if (compatible_new_size >= min and compatible_new_size <= max):
			slider_value = compatible_new_size
		elif compatible_new_size > max:
			slider_value = max
		else:
			slider_value = min
	elif old_size_box_text:
		slider_value = int(old_size_box_text)
	else:
		slider_value = int(abs(float(min - max) / 2))
	slider_line_edit.text = str(slider_value)
	slider.value = slider_value
	old_size_box_text = str(slider.value)
	slider_line_edit.caret_column = cursor_position


func _set_new_size_value():
	emit_signal("set_new_slider_value", slider.value)
