extends Node2D

signal control_event
signal level_event

@onready var tool_row = $ToolRow


func _ready():
	add_row(tool_row)
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func add_row(row) -> void:
	var window_size = get_viewport().get_visible_rect().size
	row.max_width = window_size.x
	add_child(row)
	row.connect("control_event", _on_control_event)
	row.connect("level_event", _on_level_event)
	_position_rows()


func remove_row(row) -> void:
	remove_child(row)
	_on_size_changed()


func get_height() -> float:
	var height = 0
	for row in get_children():
		height += row.get_dimensions().y
	return height


func _position_rows() -> void:
	var y = 0
	for row in get_children():
		row.position.y = y
		y += row.get_dimensions().y
	_on_size_changed()


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	position = Vector2(0, window_size.y - get_height())


func _on_control_event(event: Dictionary) -> void:
	print("EditorMenu::_on_control_event ", event)
	emit_signal("control_event", event)


func _on_level_event(event: Dictionary) -> void:
	print("EditorMenu::_on_level_event ", event)
	emit_signal("level_event", event)
