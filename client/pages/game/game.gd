extends Node2D
class_name Game

const CHARACTER = preload("res://character/character.tscn")
const MINIMAP_PENCILER = preload("res://engine/minimap_penciler.gd")

static var pr2_level_id
static var game: Game

var tiles: Tiles = Tiles.new()
var minimap_penciler: MinimapDrawer
@onready var back_button = $UI/BackButton
@onready var level_decoder = $LevelDecoder
@onready var layers = $Layers
@onready var minimap_container = $UI/Minimaps
@onready var editor_events: EditorEvents = $EditorEvents
@onready var penciler: Node2D = $Penciler
@onready var bg: Node2D = $BG


func _ready():
	back_button.connect("pressed", _on_back_pressed)
	tiles.init_defaults()
	
	# Create minimap_penciler instance
	minimap_penciler = MINIMAP_PENCILER.new()
	add_child(minimap_penciler)
	
	#
	editor_events.connect_to([level_decoder])
	layers.init(tiles)
	penciler.init(layers, bg, editor_events)
	minimap_penciler.init(layers, editor_events, minimap_container)
	
	#
	if !pr2_level_id || pr2_level_id == '0':
		activate()
	
	else:
		print("Game: Loading level id: " + pr2_level_id)
		$HTTPRequest.request_completed.connect(self._http_request_completed)
		if pr2_level_id:
			var error = $HTTPRequest.request(ApiManager.get_base_url() + "/pr2/level/" + pr2_level_id)
			if error != OK:
				push_error("An error occurred in the HTTP request.")
	
	Game.game = self


func _http_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		return
	if response.get("error", ''):
		return
	
	level_decoder.decode(response, false, layers)
	activate()


func activate():
	tiles.activate_node($Layers)
	var start_option = Start.get_next_start_option(layers)
	var character = CHARACTER.instantiate()
	
	Session.set_current_player_layer(start_option.layer_name)
	minimap_penciler.update_minimap_view(start_option.layer_name)
	for child in minimap_container.get_children():
		child.visible = child.name == start_option.layer_name
	
	var layer = layers.get_node(start_option.layer_name)
	var player_holder = layer.get_node("Players")
	character.position = Vector2((start_option.coords * Settings.tile_size) + Settings.tile_size_half).rotated(start_option.tilemap.global_rotation if start_option.tilemap else 0)
	character.active = true
	player_holder.add_child(character)
	character.init(tiles)
	character.set_depth(layer.depth)
	
	layers.calc_used_rect()


func finish():
	Main.set_scene(Main.TITLE)


func _exit_tree():
	tiles.clear()
	Game.game = null


func _on_back_pressed():
	Main.set_scene(Main.TITLE)
