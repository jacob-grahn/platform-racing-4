extends Node2D

var parent: Node2D
var camera: Camera2D


func _ready():
	parent = get_parent()
	camera = get_viewport().get_camera_2d()


func _process(delta):
	parent.position = camera.get_screen_center_position()
	parent.scale = Vector2.ONE / camera.zoom
