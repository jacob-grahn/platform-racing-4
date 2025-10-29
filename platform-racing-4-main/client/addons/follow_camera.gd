extends Node2D
## Makes the parent node follow the active camera in the viewport.
## Updates position and scale based on camera position and zoom.

var parent: Node2D


func _ready():
	parent = get_parent()


func _process(delta):
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		parent.position = camera.get_screen_center_position()
		parent.scale = Vector2.ONE / camera.zoom
		
