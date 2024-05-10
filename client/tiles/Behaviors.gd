class_name Behaviors

static var push_force = 150
static var insta_push_force = 1400

static func push_up(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity += Vector2(0, -push_force)

static func push_left(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity += Vector2(-push_force, 0)

static func push_right(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity += Vector2(push_force, 0)

static func push_down(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity += Vector2(0, push_force)

static func insta_up(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity.y = -insta_push_force

static func insta_left(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity.x = -insta_push_force

static func insta_right(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity.x = insta_push_force

static func insta_down(node: Node2D, _coords: Vector2i)->void:
	if "velocity" in node:
		node.velocity.y = insta_push_force
