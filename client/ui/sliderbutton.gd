extends Control

signal slider_value_changed

@onready var label_text = $LabelText
@onready var value_text = $ValueText
@onready var slider_button = $SliderButton
@onready var slider_popup = $SliderPopup
@onready var slider = $SliderPopup/Slider
var slider_label: String = "Label"
var slider_value: int = 1
var spawn_x: float
var spawn_y: float


func _ready() -> void:
	slider_button.pressed.connect(_show_popup)
	slider.set_new_slider_value.connect(_set_slider_value)


func _physics_process(delta: float) -> void:
	#if visible and slider_button.is_hovered() and !slider_button.is_pressed():
	#	scale = Vector2(1.25, 1.25)
	#else:
	#	scale = Vector2(1, 1)
	pass


func set_button(label: String, value: int, min: int, max: int):
	label_text.text = label
	value_text.text = str(value)
	slider.init(value, min, max)


func _show_popup(_spawn_x: float = spawn_x, _spawn_y: float = spawn_y):
	slider_popup.popup(Rect2i(global_position.x + _spawn_x, global_position.y + _spawn_y, 250, 114))


func _set_slider_value(new_slider_value: int):
	slider_value = new_slider_value
	value_text.text = str(slider_value)
	emit_signal("slider_value_changed", slider_value)
	slider_popup.hide()
