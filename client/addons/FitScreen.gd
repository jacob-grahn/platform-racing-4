extends Node2D

var size = Vector2(2048, 1024)


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	var parent = get_parent()
	var size = Vector2(
		parent.texture.get_width(), 
		parent.texture.get_height()
	)
	var ratio = window_size / size
	if ratio.x > ratio.y:
		ratio.y = ratio.x
	else:
		ratio.x = ratio.y
	parent.scale = ratio


func trigger():
	_on_size_changed()
