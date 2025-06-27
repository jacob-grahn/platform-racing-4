extends Node2D

var texture_url = "character-editor"
var default_layers: Dictionary = {
	"layers": [{
		"name": "Layer 1",
		"chunks": [],
		"rotation": 0,
		"depth": 10
	}]
}
@onready var character_display: CharacterDisplay = $UI/CharacterDisplay
@onready var character_display_timer: Timer = $UI/CharacterDisplayTimer
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _ready() -> void:
	EngineOrchestrator.init_character_editor_scene(self)
	character_display_timer.timeout.connect(_update_character_display)


func _update_character_display() -> void:
	var texture = sub_viewport.get_texture()
	var character_config = {
		"head": {
			"texture": texture,
			"color": _random_color()
		},
		"body": {
			"texture": texture,
			"color": _random_color()
		},
		"feet": {
			"texture": texture,
			"color": _random_color()
		}
	}
	character_display.set_style(character_config)
	character_display.play_random()


func _random_color() -> Color:
	return Color(
		randf(),
		randf(),
		randf()
	)
