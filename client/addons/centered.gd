extends Node2D
## Centers the parent node in the middle of the viewport.
## Updates position when viewport size changes.


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	get_parent().position = window_size / 2
