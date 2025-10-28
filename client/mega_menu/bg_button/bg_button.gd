extends IconButton

var default_texture = load("res://icon.svg")
var colors = {
	"bg": Color("ffffff"),
	"icon": Color("ffffff")
}
var editor_events: Node2D

	
func _ready() -> void:
	if LevelEditor.level_editor:
		editor_events = LevelEditor.level_editor.get_node("EditorEvents")
		editor_events.level_event.connect(_level_event)
	init(default_texture, colors, colors)


func _level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_BACKGROUND:
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % event.bg
		texture_rect.texture = await CachingLoader.load_texture(url)
	_render()
