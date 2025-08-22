extends Node2D
## Scales the parent node to fit the viewport while maintaining aspect ratio.
## Useful for background images and sprites that need to fill the screen.

var size := Vector2(0, 0)


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	var parent = get_parent()
	if not parent or not parent.texture:
		return
	var size: Vector2
	if parent.region_enabled:
		size = Vector2(parent.region_rect.size.x, parent.region_rect.size.y)
	else:
		size = Vector2(parent.texture.get_width(), parent.texture.get_height())
	parent.scale = Vector2(window_size.x / size.x, window_size.y / size.y)


func trigger():
	_on_size_changed()
