extends Node

func rasterize_node(node: Node2D, width: int, height: int) -> Image:
	var viewport := Viewport.new()
	viewport.size = Vector2(width, height)
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ONLY_NEXT_FRAME
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	viewport.attach_to_screen_rect(Rect2(Vector2(0, 0), Vector2(width, height)))
	
	var texture := viewport.get_texture()
	var image := Image.new()
	
	node.get_parent().add_child(viewport)
	viewport.add_child(node)
	
	viewport.update_worlds()
	image = texture.get_data()
	image.flip_y()
	
	viewport.queue_free()
	
	return image
