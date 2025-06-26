extends Node2D

@onready var layers = $"../../Layers"
const Editor_Cursor = preload("res://cursors/editor_cursor.tscn")
var cursor: Node2D = null

var position_history = {}

const LAG_TIME = 0.1

func _ready():
	pass

func add_new_cursor(userID: String):
	for child in get_children():
		if child.name == userID:
			return
		
	cursor = Editor_Cursor.instantiate()
	cursor.name = userID
	add_child(cursor)
	cursor.initialise(userID)
	position_history[userID] = []

func remove_cursor(myUserID: String, removeUserID: String):
	for child in get_children():
		if child.name == myUserID:
			continue
		
		if myUserID == removeUserID:
			child.queue_free()
			continue
			
		if child.name == removeUserID:
			child.queue_free()

func update_cursor_position_local(pos: Vector2, block_id: int):
	var cursor = get_children()[0]
	cursor.position = pos
	cursor.set_block_icon(block_id)
	
func update_cursor_position_remote(userID: String, pos: Vector2, layer: String, block_id: int):
	if !position_history.has(userID):
		position_history[userID] = []
		
	if userID == Session.get_username():
		return
	
	var current_time = _get_seconds_from_time_dict(Time.get_time_dict_from_system())
	position_history[userID].append({"time": current_time, "position": pos})
	
	var cutoff_time = current_time - 10.0
	position_history[userID] = position_history[userID].filter(func(entry):
		return entry["time"] >= cutoff_time
	)
	
	for child in get_children():
		if child.name == userID:
			child.set_block_icon(block_id)
			
func _process(delta):
	var current_time = _get_seconds_from_time_dict(Time.get_time_dict_from_system())

	for userID in position_history.keys():
		for child in get_children():
			if child.name == userID:
				var target_pos = find_lagged_position(userID, current_time - LAG_TIME)
				
				if target_pos != null:
					child.position = child.position.lerp(target_pos, 0.1)

func find_lagged_position(userID: String, target_time: float) -> Vector2:
	var history = position_history.get(userID, [])
	
	for i in range(history.size() - 1, -1, -1):
		var entry = history[i]
		if entry["time"] <= target_time:
			return entry["position"]
	
	return history[0]["position"] if history.size() > 0 else Vector2.ONE

func _get_seconds_from_time_dict(time_dict: Dictionary) -> float:
	return float(time_dict["hour"] * 3600 + time_dict["minute"] * 60 + time_dict["second"])
