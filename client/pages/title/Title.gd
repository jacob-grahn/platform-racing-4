extends Node2D


func _process(delta):
	$Label.rotation_degrees += delta * 50
