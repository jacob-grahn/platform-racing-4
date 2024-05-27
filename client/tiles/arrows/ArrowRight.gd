extends Arrow

var vector_right = Vector2(1, 0)


func init():
	super()
	any_side.push_back(push_right)


func push_right(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_right)
