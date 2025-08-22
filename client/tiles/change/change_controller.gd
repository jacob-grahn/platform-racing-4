extends Node2D
class_name ChangeController

var original_tile_map_layer: TileMapLayer # is there so the game doesn't crash
var change_list: Array = []
var atlas_coords: Vector2i
var blocks = {}
var change_frequency = 0
var timer = 0
var current_id = 0


func _ready():
	pass

func _physics_process(delta):
	if timer >= change_frequency:
		if (current_id + 1) >= change_list.size():
			current_id = 0
		else:
			current_id += 1
		var counter = 0
		var coords_x = -1
		var coords_y = 0
		var block_id: int = change_list.get(current_id)
		atlas_coords = CoordinateUtils.to_atlas_coords(block_id)
		for child in get_children():
			child.set_cell(Vector2i(0, 0), 0, Vector2i(atlas_coords.x,atlas_coords.y))
		timer = 0
	else:
		timer += delta
