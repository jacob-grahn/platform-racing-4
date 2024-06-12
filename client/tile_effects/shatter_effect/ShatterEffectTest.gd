extends Node2D

var ShatterEffect = preload("res://tile_effects/shatter_effect/ShatterEffect.tscn")
var tileatlas = preload("res://tiles/tileatlas.png")
@onready var timer = $Timer


func _ready():
	test()
	timer.connect("timeout", test)


func test():
	var effect = ShatterEffect.instantiate()
	effect.add_pieces(tileatlas, Vector2i(randi_range(0, 9), randi_range(0, 4)))
	effect.position = Vector2(200, 200)
	add_child(effect)
