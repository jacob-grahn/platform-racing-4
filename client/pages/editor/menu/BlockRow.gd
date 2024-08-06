extends SliderRow

signal control_event

const BLOCK_BUTTON = preload("res://pages/editor/menu/BlockButton.tscn")


func _ready():
	super._ready()
	step_delay = 0.03
	for i in range(1, 41):
		var block_button = BLOCK_BUTTON.instantiate()
		add_slider(block_button)
		block_button.set_block_id(i)
		block_button.connect("pressed", _on_pressed)


func _on_pressed(block_id: int) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})
