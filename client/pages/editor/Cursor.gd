extends Node2D
class_name Cursor

signal event

const BLOCK_DROP = 'block_drop'
const ERASE = 'erase'

@onready var control = $Control
var using_gui = false
var mode: String = BLOCK_DROP
var block_id: int = 0
var layer_id: int = 0


func _ready():
	var slider_menu = get_parent().get_node("UI/SliderMenu")
	slider_menu.connect("control_changed", _on_control_changed)
	slider_menu.connect("block_changed", _on_block_changed)
	control.connect("gui_input", _on_gui_input)


func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		using_gui = false


func _process(delta):
	if Input.is_mouse_button_pressed(1) && !using_gui: # Left click
		if mode == BLOCK_DROP:
			do_block_drop()
		if mode == ERASE:
			do_erase()
	else:
		using_gui = true


func _on_control_changed(control: String) -> void:
	if control == "Blocks":
		mode = BLOCK_DROP


func _on_block_changed(new_block_id: int) -> void:
	block_id = new_block_id


func do_block_drop():
	var mouse_position = get_global_mouse_position()
	var tilemap: TileMap = get_parent().get_node("Layers/Layer 1/TileMap")
	var coords = tilemap.local_to_map(tilemap.to_local(mouse_position))
	var atlas_coords = Helpers.to_atlas_coords(block_id)
	var existing_atlas_coords = tilemap.get_cell_atlas_coords(0, coords)
	if atlas_coords != existing_atlas_coords:
		emit_signal("event", {
			"type": "set_tile",
			"coords": coords,
			"block_id": block_id,
		})


func do_erase():
	pass
