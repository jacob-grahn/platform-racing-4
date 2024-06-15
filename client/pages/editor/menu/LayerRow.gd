extends SliderRow

var SliderTextButton: PackedScene = preload("res://pages/editor/menu/SliderTextButton.tscn")
var layer_names: Array = []
@onready var layers = get_node("../../Layers")


func _ready():
	super._ready()
	render()


func render():
	# remove existing buttons
	for existing_button in get_children():
		existing_button.queue_free()
		
	# add a button for each layer
	for layer in layers.get_children():
		var layer_name = layer.name
		var button = SliderTextButton.instantiate()
		add_slider(button)
		button.set_label(layer_name)
		button.connect("pressed", _on_pressed)
	
	# add a button to add new layers
	var button = SliderTextButton.instantiate()
	add_slider(button)
	button.set_label("+")
	button.connect("pressed", _on_new_pressed)


func select(label: String) -> void:
	for button in get_children():
		if button.get_label() == label:
			button.set_focus(true)
		else:
			button.set_focus(false)


func _on_pressed(label: String) -> void:
	select(label)


func _on_new_pressed():
	emit_signal("event", {
		"type": EditorEvents.ADD_LAYER,
		"name": "Layer 2"
	})
	call_deferred("render")
