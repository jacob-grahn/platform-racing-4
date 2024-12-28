extends Node2D

@onready var head_color_picker_button: ColorPickerButton = $HeadColorPickerButton
@onready var body_color_picker_button: ColorPickerButton = $BodyColorPickerButton
@onready var feet_color_picker_button: ColorPickerButton = $FeetColorPickerButton
@onready var character_display: CharacterDisplay = $CharacterDisplay


func _ready() -> void:
	head_color_picker_button.color = _random_color()
	body_color_picker_button.color = _random_color()
	feet_color_picker_button.color = _random_color()
	head_color_picker_button.color_changed.connect(_color_changed)
	body_color_picker_button.color_changed.connect(_color_changed)
	feet_color_picker_button.color_changed.connect(_color_changed)
	_render()


# update character display with selected config from ui
func _render() -> void:
	var character_config = {
		"head": {
			"color": head_color_picker_button.color
		},
		"body": {
			"color": body_color_picker_button.color
		},
		"feet": {
			"color": feet_color_picker_button.color
		}
	}
	character_display.set_style(character_config)


# triggered when a color picker value changes
func _color_changed(_color: Color) -> void:
	_render()


# generate a random color
func _random_color() -> Color:
	return Color(
		randf(),
		randf(),
		randf()
	)