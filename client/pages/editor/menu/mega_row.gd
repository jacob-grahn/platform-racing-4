extends SliderRow

signal control_event

const BLOCK_BUTTON: PackedScene = preload("res://pages/editor/menu/block_button.tscn")
const TEXT_BUTTON: PackedScene = preload("res://pages/editor/menu/slider_text_button.tscn")
const MUSIC_SELECTOR: PackedScene = preload("res://pages/editor/menu/music_selector/music_selector.tscn")
const SAVE_BUTTON: PackedScene = preload("res://pages/editor/menu/save_button/save_button.tscn")
const COLLAB_BUTTON: PackedScene = preload("res://pages/editor/menu/collab_button/collab_button.tscn")
var music_selector

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
