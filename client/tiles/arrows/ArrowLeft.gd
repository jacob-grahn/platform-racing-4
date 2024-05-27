extends Arrow

var vector_left = Vector2(-1, 0)


func init():
	super()
	any_side.push_back(push_left)


func push_left(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_left)
