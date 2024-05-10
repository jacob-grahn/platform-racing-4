class_name Tiles

var map = {}


func init_defaults() -> void:
	var arrow_down:BehaviorGroup = BehaviorGroup.new()
	arrow_down.any_side.push_back(Behaviors.push_down)
	arrow_down.bump.push_back(Behaviors.insta_down)
	map['5'] = arrow_down
	
	var arrow_up:BehaviorGroup = BehaviorGroup.new()
	arrow_up.any_side.push_back(Behaviors.push_up)
	arrow_up.bump.push_back(Behaviors.insta_up)
	map['6'] = arrow_up
	
	var arrow_left:BehaviorGroup = BehaviorGroup.new()
	arrow_left.any_side.push_back(Behaviors.push_left)
	arrow_left.bump.push_back(Behaviors.insta_left)
	map['7'] = arrow_left
	
	var arrow_right:BehaviorGroup = BehaviorGroup.new()
	arrow_right.any_side.push_back(Behaviors.push_right)
	arrow_right.bump.push_back(Behaviors.insta_right)
	map['8'] = arrow_right


func on(event: String, tile_type: int, source: Node2D, coords: Vector2i) -> void:
	if str(tile_type) in map:
		var behavior_group:BehaviorGroup = map[str(tile_type)]
		behavior_group.on(event, source, coords)
