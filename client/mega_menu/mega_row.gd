extends SliderRow

signal control_event

const BLOCK_BUTTON: PackedScene = preload("res://mega_menu/block_button.tscn")
const TEXT_BUTTON: PackedScene = preload("res://mega_menu/slider_text_button.tscn")
const MUSIC_SELECTOR: PackedScene = preload("res://mega_menu/music_selector/music_selector.tscn")
const SAVE_BUTTON: PackedScene = preload("res://mega_menu/save_button/save_button.tscn")
const COLLAB_BUTTON: PackedScene = preload("res://mega_menu/collab_button/collab_button.tscn")
var music_selector

# Zoom settings
var zoom_increment: int = 3
var min_zoom_increment: int = 0
var max_zoom_increment: int = 6
var zoom_amounts: Array = [25, 50, 75, 100, 150, 250, 500] #Zoom amounts listed in percentage.

func _ready():
	super._ready()
	step_delay = 0.03
	
	# Add tools
	var button_labels = ["Draw", "Erase", "Text", "BG"]
	for label in button_labels:
		var button = TEXT_BUTTON.instantiate()
		add_slider(button)
		button.set_label(label)
		button.connect("pressed", _on_tool_pressed.bind(label.to_lower()))
	
	# Add zoom buttons
	var zoom_out_button = TEXT_BUTTON.instantiate()
	add_slider(zoom_out_button)
	zoom_out_button.set_label("Zoom-")
	zoom_out_button.connect("pressed", _on_zoom_out_pressed)
	
	var zoom_in_button = TEXT_BUTTON.instantiate()
	add_slider(zoom_in_button)
	zoom_in_button.set_label("Zoom+")
	zoom_in_button.connect("pressed", _on_zoom_in_pressed)
	
	# Add music selector
	music_selector = MUSIC_SELECTOR.instantiate()
	add_slider(music_selector)
	music_selector.item_selected.connect(_music_selected)
	
	# Add save
	var save_button = SAVE_BUTTON.instantiate()
	add_slider(save_button)
	
	# Add collab toggle
	var collab_button = COLLAB_BUTTON.instantiate()
	add_slider(collab_button)
	
	# Add blocks
	for i in range(1, 41):
		var block_button = BLOCK_BUTTON.instantiate()
		add_slider(block_button)
		block_button.set_block_id(i)
		block_button.connect("pressed", _on_block_pressed.bind(i))
	
	# select the first block by default
	call_deferred("_on_block_pressed", 1)


func _music_selected(_item_id: int):
	var slug: String = music_selector.get_selected_metadata()
	Jukebox.play(slug)


func _on_block_pressed(block_id: int) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})


func _on_tool_pressed(tool_id: String) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": tool_id
	})


func _on_zoom_in_pressed() -> void:
	zoom_increment += 1
	_update_zoom()


func _on_zoom_out_pressed() -> void:
	zoom_increment -= 1
	_update_zoom()


func _update_zoom() -> void:
	zoom_increment = clamp(zoom_increment, min_zoom_increment, max_zoom_increment)
	
	emit_signal("control_event", {
		"type": "editor_camera_zoom_change",
		"zoom": 0.5 * zoom_amounts[zoom_increment] / 100.0
	})
