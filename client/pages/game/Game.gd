extends Node2D
class_name Game

static var pr2_level_id
static var game: Game

var tiles: Tiles = Tiles.new()
var target_zoom: float = 1.0

@onready var back_button = $UI/BackButton
@onready var level_decoder = $LevelDecoder


func _ready():
	back_button.connect("pressed", _on_back_pressed)	
	tiles.init_defaults()
	
	if !pr2_level_id || pr2_level_id == '0':
		activate()
	
	else:
		$HTTPRequest.request_completed.connect(self._http_request_completed)
		if pr2_level_id:
			var error = $HTTPRequest.request(Helpers.get_base_url() + "/api/pr2/level/" + pr2_level_id)
			if error != OK:
				push_error("An error occurred in the HTTP request.")
	
	Game.game = self


func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		return
	if response.get("error", ''):
		return
	
	level_decoder.decode(response)
	activate()


func activate():
	tiles.activate_node($Layers)
	$Character.position = Start.get_next_start_coords() * Settings.tile_size + Settings.tile_size_half
	$Character.active = true


func _exit_tree():
	Game.game = null


func _on_back_pressed():
	Helpers.set_scene("TITLE")
