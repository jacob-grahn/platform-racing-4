extends Node2D

var loop_width = 4096
var size = Vector2(2048, 1024)


func _ready():
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move($Hay4, -delta * 16)
	_move($Hay3, -delta * 32)
	_move($Hay2, -delta * 100)
	_move($Hay1, -delta * 1500)


func _move(node: Node2D, dist: float):
	node.position.x += dist
	if node.position.x <= -loop_width:
		node.position.x += loop_width
	if node.position.x >= loop_width:
		node.position.x -= loop_width


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	var ratio = window_size / size
	if ratio.x > ratio.y:
		ratio.y = ratio.x
	else:
		ratio.x = ratio.y
	scale = ratio
	position = window_size / 2
	$Hay5.position.x = (-position.x / 2) * (1/scale.x) - 2400
	
