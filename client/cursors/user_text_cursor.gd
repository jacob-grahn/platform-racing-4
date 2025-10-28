extends Node2D

signal level_event

var active: bool = false
var current_textbox: TextEdit
var layers: Layers


func deactivate():
	active = false


func activate():
	active = true


func _process(_delta):
	if active:
		visible = true
		var touching_gui: bool = get_parent().touching_gui
	else:
		visible = false


func init(_layers: Layers) -> void:
	layers = _layers
	

func on_mouse_down():
	if active:
		var layer: ParallaxBackground = layers.art_layers.get_node(layers.get_target_art_layer())
		var textboxes: Node2D = layer.get_node("Texts")
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = textboxes.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))

		var textbox_background_color = Color(1.0, 0.0, 0.0, 0.0)
		var textbox_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
		var textbox_font_size = 150
	
		emit_signal("level_event", {
			"type": EditorEvents.ADD_TEXT,
			"layer_name": layers.art_layers.get_target_art_layer(),
			"position": {
				"x": mouse_position.round().x,
				"y": mouse_position.round().y
			},
			"width": 1,
			"height": 1,
			"text_rotation": 0,
			"text": "Text!",
			"font": textbox_font,
			"font_size": textbox_font_size
		})
	
		self.get_parent().get_node("Control").mouse_filter = 2 #edit text mode until add text is reselected


func on_drag():
	pass


func on_mouse_up():
	pass
