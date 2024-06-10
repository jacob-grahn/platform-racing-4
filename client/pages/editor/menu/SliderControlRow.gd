extends SliderRow

signal pressed

var SliderTextButton: PackedScene = preload("res://pages/editor/menu/SliderTextButton.tscn")
var button_labels = ["Blocks", "Stamps", "Draw", "Select", "Erase", "Undo", "Redo", "Layers"]


func _ready():
	super._ready()
	for label in button_labels:
		var button = SliderTextButton.instantiate()
		add_slider(button)
		button.set_label(label)
		button.connect("pressed", _on_pressed)


func _process(delta):
	pass


func select(label: String) -> void:
	for button in get_children():
		if button.get_label() == label:
			button.set_focus(true)
		else:
			button.set_focus(false)
	emit_signal("pressed", label)


func _on_pressed(label: String) -> void:
	select(label)
