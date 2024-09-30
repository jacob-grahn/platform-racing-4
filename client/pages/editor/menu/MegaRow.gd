extends SliderRow

signal control_event

const BLOCK_BUTTON = preload("res://pages/editor/menu/BlockButton.tscn")
var TEXT_BUTTON: PackedScene = preload("res://pages/editor/menu/SliderTextButton.tscn")


func _ready():
	super._ready()
	step_delay = 0.03
	
	# Add tools
	var button_labels = ["Draw", "Erase", "Text"]
	for label in button_labels:
		var button = TEXT_BUTTON.instantiate()
		add_slider(button)
		button.set_label(label)
		button.connect("pressed", _on_tool_pressed.bind(label.to_lower()))
		
	# Add blocks
	for i in range(1, 41):
		var block_button = BLOCK_BUTTON.instantiate()
		add_slider(block_button)
		block_button.set_block_id(i)
		block_button.connect("pressed", _on_block_pressed.bind(i))
	
	# select the first block by default
	call_deferred("_on_block_pressed", 1)


func _on_block_pressed(block_id: int) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})


func _on_tool_pressed(tool_id: String) -> void:
	print("on tool pressed")
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": tool_id
	})
