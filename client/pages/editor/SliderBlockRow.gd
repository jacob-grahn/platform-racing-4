extends SliderRow

signal pressed

const SliderBlockButton = preload("res://pages/editor/SliderBlockButton.tscn")


func _ready():
	for i in range(0, 38):
		var block_button = SliderBlockButton.instantiate()
		var coords = Helpers.to_atlas_coords(i)
		add_slider(block_button)
		block_button.set_coords(coords)
		block_button.connect("pressed", _on_pressed)


func select(atlas_coords: Vector2i) -> void:
	emit_signal("pressed", atlas_coords)


func _on_pressed(atlas_coords: Vector2i) -> void:
	print('pressed ', atlas_coords)
	select(atlas_coords)
