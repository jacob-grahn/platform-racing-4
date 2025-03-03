extends Node2D

var tiles: Tiles = Tiles.new()


func _ready():
	tiles.init_defaults()
	tiles.activate(self)
	$Character.active = true
