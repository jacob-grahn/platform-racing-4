class_name BehaviorGroup

var top = []
var left = []
var right = []
var bottom = []
var any_side = [] # includes top, left, right, and bottom
var stand = [] # could be any side depending on player rotation
var bump = [] # could be any side depending on player rotation
var tick = [] # will run on some interval

func on(event: String, source: Node2D, coords: Vector2i) -> void:
	# print('BehaviorGroup ', event, ' ', source, ' ', coords)
	for behavior in self[event]:
		behavior.call(source, coords)
