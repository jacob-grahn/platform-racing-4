extends Node2D

signal level_event

var current_usertextbox: Label


func on_mouse_down():
	var layer_name = get_parent().layer_name
	var layer: ParallaxBackground = get_node("../../../Layers/"+layer_name)
	var textboxes: Node2D = layer.get_node("UserTextboxes")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = textboxes.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	current_usertextbox = Label.new()
	textboxes.add_child(current_usertextbox)
	current_usertextbox.position = mouse_position.round()
	current_usertextbox.text = "Default Text!"
	current_usertextbox.autowrap_mode = 1
	var usertextbox_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
	var usertextbox_font_size = 150
	current_usertextbox.set("theme_override_fonts/font", usertextbox_font)
	current_usertextbox.set("theme_override_font_sizes/font_size", usertextbox_font_size)
	current_usertextbox.size.x = 600
		
	emit_signal("level_event", {
		"type": EditorEvents.ADD_USERTEXT,
		"layer_name": get_parent().layer_name,
		"position": current_usertextbox.position,
		"usertext": current_usertextbox.text,
		"font": usertextbox_font,
		"font_size": usertextbox_font_size,
		"autowrap_mode": current_usertextbox.autowrap_mode,
		"text_width": current_usertextbox.size.x
	})
		
	current_usertextbox.queue_free()


func on_drag():
	pass


func on_mouse_up():
	pass
