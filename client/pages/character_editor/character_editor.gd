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
@onready var editor_events: EditorEvents = $EditorEvents
@onready var layers: Layers = $SubViewportContainer/SubViewport/Layers
@onready var cursor: Cursor = $UI/Cursor
@onready var editor_menu: Node2D = $UI/EditorMenu
@onready var layer_panel: Node2D = $UI/LayerPanel
@onready var character_display: CharacterDisplay = $UI/CharacterDisplay
@onready var character_display_timer: Timer = $UI/CharacterDisplayTimer
@onready var level_decoder: Node2D = $LevelDecoder
@onready var penciler: Node2D = $Penciler
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport


func _ready() -> void:
	cursor.init(editor_menu, layers)
	editor_events.connect_to([cursor, editor_menu, layer_panel, level_decoder])
	character_display_timer.timeout.connect(_update_character_display)
	layer_panel.init(layers)
	penciler.init(layers, null, editor_events)
	level_decoder.decode(default_layers, true, layers)


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
