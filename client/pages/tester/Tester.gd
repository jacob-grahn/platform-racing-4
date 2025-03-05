extends Node2D

const CHARACTER = preload("res://character/character.tscn")
const MINIMAP_PENCILER = preload("res://pages/editor/minimap_penciler.gd")

@onready var layers = $Layers
@onready var level_decoder = $LevelDecoder
@onready var back = $UI/Back
@onready var minimap_container = $UI/Minimaps
@onready var editor_events: EditorEvents = $EditorEvents
@onready var penciler: Node2D = $Penciler

var tiles: Tiles = Tiles.new()
var minimap_penciler: MinimapDrawer


func _ready():
	tiles.init_defaults()
	back.connect("pressed", _on_back_pressed)
	Jukebox.play("pr1-future-penumbra")
	
	# Create minimap_penciler instance
	minimap_penciler = MINIMAP_PENCILER.new()
	add_child(minimap_penciler)


func _on_back_pressed():
	Main.set_scene(Main.LEVEL_EDITOR)


func init(level: Dictionary):
	penciler.init(layers)
	minimap_penciler.init(layers, editor_events, minimap_container)
	editor_events.connect_to([level_decoder])
	level_decoder.decode(level, false, layers)
	layers.init(tiles)
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
	character.set_depth(layer.depth)

	layers.calc_used_rect()


func finish():
	Main.set_scene(Main.LEVEL_EDITOR)


func _exit_tree():
	tiles.clear()
