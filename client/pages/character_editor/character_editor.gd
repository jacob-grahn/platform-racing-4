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
	var level_manager: LevelManager = get_node("SubViewportContainer/SubViewport/LevelManager")
	var penciler: Node2D = get_node("Penciler")
	var editor_events: EditorEvents = get_node("EditorEvents")
	var cursor: Cursor = get_node("UI/Cursor")
	var editor_menu = get_node("UI/EditorMenu")
	var layer_panel = get_node("UI/LayerPanel")
	
	cursor.init(editor_menu, level_manager.layers)
	editor_events.connect_to([cursor, editor_menu, layer_panel, level_manager.level_decoder])
	penciler.init(level_manager.layers, null, editor_events)
	level_manager.decode_level(default_layers, true)
	layer_panel.init(level_manager.layers)
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
