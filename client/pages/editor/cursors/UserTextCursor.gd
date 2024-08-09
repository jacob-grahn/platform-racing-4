extends Node2D

signal level_event

var current_usertextbox: TextEdit


func on_mouse_down():
	var layer_name = get_parent().layer_name
	var layer: ParallaxBackground = get_node("../../../Layers/"+layer_name)
	var textboxes: Node2D = layer.get_node("UserTextboxes")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = textboxes.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	current_usertextbox = TextEdit.new()
	textboxes.add_child(current_usertextbox)
	current_usertextbox.position = mouse_position.round()
	current_usertextbox.text = "Default Text!"
	current_usertextbox.wrap_mode = 1
	current_usertextbox.autowrap_mode = 1
	current_usertextbox.size.x = 1800
	current_usertextbox.size.y = 600
	var usertextbox_background_color = Color(1.0, 0.0, 0.0, 0.0)
	var usertextbox_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
	var usertextbox_font_size = 150
	current_usertextbox.set("theme_override_fonts/font", load(usertextbox_font))
	current_usertextbox.set("theme_override_font_sizes/font_size", usertextbox_font_size)
	var usertextbox_bg = StyleBoxFlat.new()
	current_usertextbox.set("theme_override_styles/normal", usertextbox_bg)
	usertextbox_bg.set_bg_color(usertextbox_background_color)


func on_drag():
	var layer_name = get_parent().layer_name
	var layer: ParallaxBackground = get_node("../../../Layers/"+layer_name)
	var textboxes: Node2D = layer.get_node("UserTextboxes")
	var camera: Camera2D = get_viewport().get_camera_2d()
	var mouse_position = textboxes.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
	current_usertextbox.position = mouse_position.round()


func on_mouse_up():
	var usertextbox_background_color = Color(1.0, 0.0, 0.0, 0.0)
	var usertextbox_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
	var usertextbox_font_size = 150
	
	emit_signal("level_event", {
		"type": EditorEvents.ADD_USERTEXT,
		"layer_name": get_parent().layer_name,
		"position": current_usertextbox.position,
		"usertext": current_usertextbox.text,
		"wrap_mode": current_usertextbox.wrap_mode,
		"autowrap_mode": current_usertextbox.autowrap_mode,
		"font": usertextbox_font,
		"font_size": usertextbox_font_size,
		"background_color": usertextbox_background_color,
		"text_width": current_usertextbox.size.x,
		"text_height": current_usertextbox.size.y
	})
		
	current_usertextbox.queue_free()
	self.get_parent().get_node("Control").mouse_filter = 2 #edit text mode until add text is reselected
