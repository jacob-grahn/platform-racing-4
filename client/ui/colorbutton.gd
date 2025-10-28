extends Control

signal colorbutton_color_changed

@onready var color_button = $TextureButton
@onready var colorin = $TextureButton/Colorin
@onready var color_picker_popup = $ColorPickerPopup
@onready var color_picker = $ColorPickerPopup/ColorPicker
var color: Color = Color("000000FF")
var spawn_x: float
var spawn_y: float


func _ready() -> void:
	color_button.pressed.connect(_show_popup)
	color_picker.connect("set_new_color", _change_color)
	colorin.self_modulate = color


func set_color(new_color: Color):
	color = new_color
	color_picker._set_color(color)
	colorin.self_modulate = color


func _show_popup(_spawn_x: float = spawn_x, _spawn_y: float = spawn_y):
	color_picker.previous_color = color
	color_picker.set_previous_color_rect()
	color_picker_popup.popup(Rect2i(global_position.x + _spawn_x, global_position.y + _spawn_y, 430, 452))


func _change_color(new_color: Color):
	color = new_color
	emit_signal("colorbutton_color_changed", color)
	colorin.self_modulate = color
	color_picker_popup.visible = false
