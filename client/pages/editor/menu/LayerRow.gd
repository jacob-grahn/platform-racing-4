extends SliderRow
class_name LayerRow

signal level_event
signal control_event

static var selected_layer_name: String = "L1"

@onready var layers = get_node("../../../Layers")
@onready var editor = get_node("../../../")
@onready var menu = get_node("../")

const SLIDER_TEXT_BUTTON: PackedScene = preload("res://pages/editor/menu/SliderTextButton.tscn")
const LAYER_CONTROL_ROW: PackedScene = preload("res://pages/editor/menu/LayerControlRow.tscn")
var layer_names: Array = []
var layer_control_row


func _ready():
	super._ready()
	
	layer_control_row = LAYER_CONTROL_ROW.instantiate()
	menu.add_row(layer_control_row)
	
	render()


func render():
	# remove existing buttons
	pos = Vector2i(0, 0)
	for existing_button in get_children():
		existing_button.queue_free()
		
	# add a button for each layer
	for layer in layers.get_children():
		var layer_name = layer.name
		var button = SLIDER_TEXT_BUTTON.instantiate()
		add_slider(button)
		button.set_label(layer_name)
		button.connect("pressed", _on_pressed)
	
	# add a button to add new layers
	var button = SLIDER_TEXT_BUTTON.instantiate()
	add_slider(button)
	button.set_label("+")
	button.connect("pressed", _on_new_pressed)
	
	# select the currently active layer
	select(selected_layer_name)
	layer_control_row.layer_name = selected_layer_name


func select(label: String) -> void:
	selected_layer_name = label
	layer_control_row.set_layer_name(selected_layer_name)
	for button in get_children():
		if button.get_label() == label:
			button.set_focus(true)
		else:
			button.set_focus(false)


func _on_pressed(label: String) -> void:
	select(label)
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_LAYER,
		"layer_name": label
	})


func _on_new_pressed(label: String) -> void:
	emit_signal("level_event", {
		"type": EditorEvents.ADD_LAYER,
		"name": "L" + str(layers.get_child_count() + 1)
	})
	call_deferred("render")


func _exit_tree():
	if layer_control_row:
		layer_control_row.queue_free()
		layer_control_row = null
