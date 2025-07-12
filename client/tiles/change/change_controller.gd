extends Node2D
class_name ChangeController

var default_change_list: Array = [1, 5, 18, 27, 16, 26, 11, 10, 23, 22, 28, 25, 19, 21, 33, 32, 34, 13, 7, 6, 8, 9, 29, 30, 37, 38, 39]
var blocks = {}
var timer = 0
var current_id = 0
var pr3_compatibility = true


func _ready():
	pass

func _physics_process(delta):
	if timer >= 2.5:
		if pr3_compatibility and current_id >= 21 or current_id >= default_change_list.size():
			current_id = 0
		else:
			current_id += 1
		var counter = 0
		var coords_x = -1
		var coords_y = 0
		while counter < default_change_list.get(current_id):
			counter += 1
			if coords_x >= 9:
				coords_y += 1
				coords_x = 0
			else:
				coords_x += 1
		for child in get_children():
			child.set_cell(Vector2i(0, 0), 0, Vector2i(coords_x, coords_y))
		timer = 0
	else:
		timer += delta
