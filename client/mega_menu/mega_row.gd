extends SliderRow
class_name MegaRow

signal control_event

const BLOCK_BUTTON: PackedScene = preload("res://mega_menu/block_button.tscn")
const ICON_BUTTON: PackedScene = preload("res://ui/icon_button.tscn")
const MUSIC_SELECTOR: PackedScene = preload("res://mega_menu/music_selector/music_selector.tscn")
const SAVE_BUTTON: PackedScene = preload("res://mega_menu/save_button/save_button.tscn")
const COLLAB_BUTTON: PackedScene = preload("res://mega_menu/collab_button/collab_button.tscn")
const BG_BUTTON: PackedScene = preload("res://mega_menu/bg_button/bg_button.tscn")
const ZOOM_IN_BUTTON: PackedScene = preload("res://mega_menu/zoom_in/zoom_in_button.tscn")
const ZOOM_OUT_BUTTON: PackedScene = preload("res://mega_menu/zoom_out/zoom_out_button.tscn")
const GAME_CONFIG_BUTTON: PackedScene = preload("res://pages/level_editor/game_config_button.tscn")

var music_selector
var bg_button
var current_bg_id = ""
var tool_buttons = []
var active_button = null
var zoom_controller: ZoomController = ZoomController.new()
var active_colors = EditorMenu.COLORS.tools.active
var inactive_colors = EditorMenu.COLORS.tools.inactive

@onready var editor_events: Node2D = get_node("/root/Main/LEVEL_EDITOR/EditorEvents")

func _ready():
	super._ready()
	
	# Add the zoom controller as a child
	get_parent().call_deferred("add_child", zoom_controller)
	zoom_controller.zoom_changed.connect(_on_control_event)
	
	# Add tools
	var tool_configs = [
		{"label": "Draw", "icon": "draw"},
		{"label": "Erase", "icon": "erase"},
		{"label": "Text", "icon": "text"}
	]
	
	for config in tool_configs:
		var button = ICON_BUTTON.instantiate()
		add_slider(button)
		var texture = load("res://mega_menu/icons/" + config.icon + ".png")
		button.init(texture, active_colors, inactive_colors)
		button.texture_button.pressed.connect(_on_tool_pressed.bind(config.label.to_lower(), button))
		tool_buttons.append(button)
	
	# Add BG button
	bg_button = BG_BUTTON.instantiate()
	add_slider(bg_button)
	bg_button.texture_button.pressed.connect(_on_tool_pressed.bind("bg", bg_button))
	tool_buttons.append(bg_button)
	
	# Add zoom buttons
	var zoom_out_button = ZOOM_OUT_BUTTON.instantiate()
	add_slider(zoom_out_button)
	zoom_out_button.setup(zoom_controller)
	
	var zoom_in_button = ZOOM_IN_BUTTON.instantiate()
	add_slider(zoom_in_button)
	zoom_in_button.setup(zoom_controller)
	
	# Add music selector
	music_selector = MUSIC_SELECTOR.instantiate()
	add_slider(music_selector)
	
	# Add save
	var save_button = SAVE_BUTTON.instantiate()
	add_slider(save_button)
	
	# Add collab toggle
	var collab_button = COLLAB_BUTTON.instantiate()
	add_slider(collab_button)

	# Add game config toggle
	var game_config_button = GAME_CONFIG_BUTTON.instantiate()
	add_slider(game_config_button)
	
	# Add blocks
	for i in range(1, 41):
		var block_button = BLOCK_BUTTON.instantiate()
		add_slider(block_button)
		block_button.set_block_id(i)
		block_button.connect("pressed", _on_block_pressed.bind(i, block_button))
		tool_buttons.append(block_button)
	
	# select the first block by default
	call_deferred("_on_block_pressed", 1, tool_buttons[tool_buttons.size() - 40])


func _on_block_pressed(block_id: int, button = null) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})
	
	if button:
		_deactivate_all_except(button)


func _on_tool_pressed(tool_id: String, button = null) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": tool_id
	})
	
	if button:
		_deactivate_all_except(button)


func _on_control_event(event: Dictionary) -> void:
	emit_signal("control_event", event)


func _deactivate_all_except(active_button_ref) -> void:
	active_button = active_button_ref
	
	# Activate the selected button
	if active_button and active_button.has_method("set_active"):
		active_button.set_active(true)
	
	# Deactivate all other buttons
	for button in tool_buttons:
		if button != active_button and button.has_method("set_active"):
			button.set_active(false)
