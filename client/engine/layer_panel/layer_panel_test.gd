extends Node2D

var tile_config: Tiles = Tiles.new()
@onready var layer_panel = $LayerPanel
@onready var layers = $Layers


func _ready():
	tile_config.init_defaults()
	layers.init(tile_config)
	layer_panel.init(layers)
	layer_panel.level_event.connect(_on_level_event)


func _on_level_event(event):
	if event.type == EditorEvents.ADD_LAYER:
		layers.add_layer(event.name)
	if event.type == EditorEvents.DELETE_LAYER:
		layers.remove_layer(event.name)
