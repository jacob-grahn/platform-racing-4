extends IconButton


func _ready() -> void:
	var editor_events = get_node("../../../../EditorEvents")
	editor_events.level_event.connect(_level_event)


func _level_event(event: Dictionary) -> void:
	if event.type == EditorEvents.SET_BACKGROUND:
		var url = "https://files.platformracing.com/backgrounds/%s.jpg" % event.bg
		texture_rect.texture = await CachingLoader.load_texture(url)
	_render()
