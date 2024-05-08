extends Node2D
class_name Game

static var pr2_level_id


func _ready():
	$HTTPRequest.request_completed.connect(self._http_request_completed)
	if pr2_level_id:
		var error = $HTTPRequest.request(Helpers.get_base_url() + "/api/pr2/level/" + pr2_level_id)
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		return
	if response.get("error", ''):
		return
	
	var tile_layer = response.layers[0]
	var chunks = tile_layer.chunks
	for chunk in chunks:
		for i:int in chunk.data.size():
			var tile_type:int = chunk.data[i] - 1
			if tile_type == -1:
				continue
			var layer = 0
			var coords = Vector2i(chunk.x + (i % int(chunk.width)), chunk.y + (i / int(chunk.width)))
			var source_id = 0
			var atlas_coords = Vector2i(tile_type % 10, tile_type / 10)
			var alternative_tile = 0
			# print(tile_type, ' ', coords, ' ', atlas_coords)
			$TileMap.set_cell(layer, coords, source_id, atlas_coords, alternative_tile)
			if tile_type == 11:
				print('found start pos ', coords)
				$CharacterBody2D.position = Vector2(coords.x * 128, coords.y * 128)
	
	
	$CharacterBody2D.active = true
