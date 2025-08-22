extends SliderRow
class_name LevelOptionsMenu

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
const BLOCK_LIST: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 35, 36, 37, 38, 39, 40, 41, 42, 43]

var music_selector
var bg_button
var current_bg_id = ""
var tool_buttons = []
var active_button = null
var zoom_controller: ZoomController = ZoomController.new()
var active_colors = EditorMenu.COLORS.tools.active
var inactive_colors = EditorMenu.COLORS.tools.inactive

func _ready():
	super._ready()
	
	# Add the zoom controller as a child
	get_parent().call_deferred("add_child", zoom_controller)
	zoom_controller.zoom_changed.connect(_on_control_event)
	
	# Add tools
	var tool_configs = [
		{"label": "BlockMenu", "icon": "blocks", "description": "Design your level."},
		{"label": "ArtMenu", "icon": "art", "description": "Unleash your inner Da Vincis unto the map."},
		{"label": "SettingsMenu", "icon": "settings", "description": "Settings for the level. Adjust them to your liking."},
		{"label": "ExtraOptionsMenu", "icon": "extraoptions", "description": "Save or load levels, or jump to other areas of the game."},
		{"label": "TestLevelButton", "icon": "test", "description": "Starts the level for playtesting."}
	]
	
	for config in tool_configs:
		var button = ICON_BUTTON.instantiate()
		add_slider(button)
		var texture = load("res://mega_menu/icons/" + config.icon + ".png")
		button.init(texture, active_colors, inactive_colors)
		button.texture_button.pressed.connect(_on_submenu_button_pressed.bind(config.label.to_lower(), button))
		button.texture_button.tooltip_text = config.description
		tool_buttons.append(button)
	
	# Add BG button
	#bg_button = BG_BUTTON.instantiate()
	#add_slider(bg_button)
	#bg_button.texture_button.pressed.connect(_on_tool_pressed.bind("bg", bg_button))
	#tool_buttons.append(bg_button)
	
	# Add zoom buttons
	#var zoom_out_button = ZOOM_OUT_BUTTON.instantiate()
	#add_slider(zoom_out_button)
	#zoom_out_button.setup(zoom_controller)
	
	#var zoom_in_button = ZOOM_IN_BUTTON.instantiate()
	#add_slider(zoom_in_button)
	#zoom_in_button.setup(zoom_controller)
	
	# Add music selector
	#music_selector = MUSIC_SELECTOR.instantiate()
	#add_slider(music_selector)
	
	# Add save
	#var save_button = SAVE_BUTTON.instantiate()
	#add_slider(save_button)
	
	# Add collab toggle
	#var collab_button = COLLAB_BUTTON.instantiate()
	#add_slider(collab_button)
	
	# Add game config toggle
	#var game_config_button = GAME_CONFIG_BUTTON.instantiate()
	#add_slider(game_config_button)
	
	# Add blocks
	#for i in len(BLOCK_LIST):
	#	var block_button = BLOCK_BUTTON.instantiate()
	#	add_slider(block_button)
	#	block_button.set_block_id(BLOCK_LIST[i])
	#	block_button.connect("pressed", _on_block_pressed.bind(BLOCK_LIST[i], block_button))
	#	tool_buttons.append(block_button)
	
	# select the first block by default
	call_deferred("_on_submenu_button_pressed", "BlockMenu", tool_buttons[0])


func _on_block_pressed(block_id: int, button = null) -> void:
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})
	
	if button:
		_deactivate_all_except(button)


func _on_submenu_button_pressed(submenu: String, button = null) -> void:
	#emit_signal("control_event", {
	#	"type": EditorEvents.SELECT_SUBMENU,
	#	"submenu": submenu
	#})
	pass
	
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
