extends Node2D

const BODY_IDS = ['racer', 'smiler']
var BASE_URL = Main.FILE_URL + "/characters"
@onready var head_color_picker_button: ColorPickerButton = $HeadColorPickerButton
@onready var body_color_picker_button: ColorPickerButton = $BodyColorPickerButton
@onready var feet_color_picker_button: ColorPickerButton = $FeetColorPickerButton
@onready var randomize_button: Button = $RandomizeButton
@onready var character_display: CharacterDisplay = $CharacterDisplay


func _ready() -> void:
	head_color_picker_button.color_changed.connect(_color_changed)
	body_color_picker_button.color_changed.connect(_color_changed)
	feet_color_picker_button.color_changed.connect(_color_changed)
	randomize_button.pressed.connect(_randomize_button_pressed)
	_randomize()


# update character display with selected config from ui
func _render() -> void:
	var character_config = {
		"head": {
			"url": BASE_URL + "/" + _random_body() + ".webp",
			"color": head_color_picker_button.color
		},
		"body": {
			"url": BASE_URL + "/" + _random_body() + ".webp",
			"color": body_color_picker_button.color
		},
		"feet": {
			"url": BASE_URL + "/" + _random_body() + ".webp",
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


#
func _random_body() -> String:
	var i = randi_range(0, len(BODY_IDS) - 1)
	return BODY_IDS[i]


func _randomize_button_pressed() -> void:
	_randomize()


func _randomize() -> void:
	head_color_picker_button.color = _random_color()
	body_color_picker_button.color = _random_color()
	feet_color_picker_button.color = _random_color()
	_render()
