extends Arrow
class_name ArrowDown

var vector_down = Vector2(0, 1)


func init():
	super()
	any_side.push_back(push_down)


func push_down(node: Node2D, target: Node2D, coords: Vector2i)->void:
	push(node, target, coords, vector_down)
