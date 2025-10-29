extends Node2D

var tiles: Tiles = Tiles.new()


func _ready():
	tiles.init_defaults()
	tiles.activate_node(self)
	$Character.active = true
