extends SliderRow

signal pressed

const SliderBlockButton = preload("res://pages/editor/menu/SliderBlockButton.tscn")


func _ready():
	super._ready()
	step_delay = 0.03
	for i in range(1, 40):
		var block_button = SliderBlockButton.instantiate()
		add_slider(block_button)
		block_button.set_block_id(i)
		block_button.connect("pressed", _on_pressed)


func _on_pressed(block_id: int) -> void:
	emit_signal("pressed", block_id)
