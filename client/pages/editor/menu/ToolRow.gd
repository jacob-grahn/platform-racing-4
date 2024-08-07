extends SliderRow

signal control_event

const BLOCK_ROW: PackedScene = preload("res://pages/editor/menu/BlockRow.tscn")
const LAYER_ROW: PackedScene = preload("res://pages/editor/menu/LayerRow.tscn")
var TEXT_BUTTON: PackedScene = preload("res://pages/editor/menu/SliderTextButton.tscn")
var button_labels = ["Blocks", "Stamps", "Draw", "Select", "Erase", "Undo", "Redo", "Layers", "Add Text"]
var sub_row
var menu


func _ready():
	super._ready()
	menu = get_parent()
	for label in button_labels:
		var button = TEXT_BUTTON.instantiate()
		add_slider(button)
		button.set_label(label)
		button.connect("pressed", _on_pressed)
	
	self.call_deferred("_on_pressed", "Blocks")


func _on_pressed(label: String) -> void:
	for button in get_children():
		if button.get_label() == label:
			button.set_focus(true)
		else:
			button.set_focus(false)
	
	if sub_row && sub_row.name == label:
		return
	
	if sub_row:
		menu.remove_row(sub_row)
		sub_row = null
	
	if label == "Blocks":
		sub_row = BLOCK_ROW.instantiate()
	if label == "Layers":
		sub_row = LAYER_ROW.instantiate()
	
	if sub_row:
		sub_row.name = label
		menu.call_deferred("add_row", sub_row)
	
	emit_signal("control_event", {
		type = EditorEvents.SELECT_TOOL,
		tool = label.to_lower()
	})
