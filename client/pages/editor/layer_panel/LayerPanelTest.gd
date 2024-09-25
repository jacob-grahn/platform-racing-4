extends Node2D

@onready var layer_panel = $LayerPanel
@onready var layers = $Layers


func _ready():
	layer_panel.set_layers(layers)
