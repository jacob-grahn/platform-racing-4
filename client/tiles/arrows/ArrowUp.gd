extends Arrow
class_name ArrowUp

var vector_up = Vector2(0, -1)


func init():
	super()
	any_side.push_back(push_up)


func push_up(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_up)
