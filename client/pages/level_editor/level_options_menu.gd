extends Control

signal control_event
signal level_event

@onready var selection_glow = $SelectionGlow
@onready var button_list = $Buttons
@onready var block_menu_button = $Buttons/BlockMenuButton/TextureButton
@onready var art_menu_button = $Buttons/ArtMenuButton/TextureButton
@onready var level_settings_button = $Buttons/LevelSettingsButton/TextureButton
@onready var collab_button = $Buttons/CollabButton/TextureButton
@onready var level_settings_dropdown_button = $Buttons/ExtraOptionsButton/LevelSettingsDropdownButton
@onready var extra_options_button = $Buttons/ExtraOptionsButton/TextureButton
@onready var test_level_button = $Buttons/TestLevelButton/TextureButton
@onready var submenus = $Submenus
@onready var block_submenu = $Submenus/BlockSubmenu
@onready var art_submenu = $Submenus/ArtSubmenu
var current_submenu: Control
var layers: Node2D
var editor_events: EditorEvents
var editor: Node2D
var selected_button: TextureButton
var old_selected_button: TextureButton
var settings_list: Dictionary = {
	"undo": {
		"setting_name": "Undo (CTRL + Z)",
		"setting_func": "",
		"use_seperator": false,
		},
	"redo": {
		"setting_name": "Redo (CTRL + Y)",
		"setting_func": "",
		"use_seperator": true,
		},
	"new": {
		"setting_name": "New",
		"setting_func": "",
		"use_seperator": false,
		},
	"load": {
		"setting_name": "Load",
		"setting_func": "",
		"use_seperator": false,
		},
	"save": {
		"setting_name": "Save",
		"setting_func": "",
		"use_seperator": true,
		},
	"import": {
		"setting_name": "Import",
		"setting_func": "",
		"use_seperator": false,
		},
	"export": {
		"setting_name": "Export",
		"setting_func": "",
		"use_seperator": true,
		},
	"gotoothereditor": {
		"setting_name": "Not implemented",
		"setting_func": "",
		"use_seperator": false,
		},
	"gotootherpage": {
		"setting_name": "Lobby/MainMenu",
		"setting_func": "",
		"use_seperator": true,
		},
	"nevermind": {
		"setting_name": "Never Mind",
		"setting_func": "",
		"use_seperator": false,
		},
}


func _ready() -> void:
	block_menu_button.pressed.connect(_click_block_menu.bind(block_menu_button))
	art_menu_button.pressed.connect(_click_block_menu.bind(art_menu_button))
	level_settings_button.pressed.connect(_click_block_menu.bind(level_settings_button))
	collab_button.pressed.connect(_click_block_menu.bind(collab_button))
	for option in settings_list:
		var label = settings_list[option].setting_name
		var has_seperator = settings_list[option].use_seperator
		level_settings_dropdown_button.get_popup().add_item(label)
		if has_seperator:
			level_settings_dropdown_button.get_popup().add_separator()
	test_level_button.pressed.connect(_on_test_pressed)
	selected_button = block_menu_button
	set_submenu()


func init(new_layers: Node2D, new_editor_events: EditorEvents) -> void:
	layers = new_layers
	editor_events = new_editor_events
	for child in submenus.get_children():
		if "control_event" in child:
			child.control_event.connect(_on_control_event)
		if "level_event" in child:
			child.level_event.connect(_on_level_event)
		if "layers" in child or "editor_events" in child:
			if "layers" in child:
				child.layers = layers
			if "editor_events" in child:
				child.editor_events = editor_events
			child.init()


func _physics_process(delta: float) -> void:
	for child in button_list.get_children():
		for node in child.get_children():
			if node is TextureButton or node is MenuButton:
				if node.is_hovered() and !node.is_pressed():
					node.get_parent().scale = Vector2(1.25, 1.25)
				else:
					node.get_parent().scale = Vector2(1, 1)
				if selected_button.get_parent() == node.get_parent():
					node.self_modulate = Color("ffffff")
				else:
					node.self_modulate = Color("2a9fd6")
			elif node is ColorRect:
				if selected_button.get_parent() == node.get_parent():
					node.self_modulate = Color("2a9fd6")
				else:
					node.self_modulate = Color("ffffff")
					
	if old_selected_button != selected_button:
		set_submenu()
		old_selected_button = selected_button
	set_selection_glow()


func set_submenu():
	if current_submenu:
		current_submenu.deactivate()
	if selected_button == block_menu_button:
		current_submenu = block_submenu
	elif selected_button == art_menu_button:
		current_submenu = art_submenu
	current_submenu.activate()


func _on_control_event(event: Dictionary) -> void:
	print("LevelOptionsMenu::_on_control_event ", event)
	control_event.emit(event)


func _on_level_event(event: Dictionary) -> void:
	print("LevelOptionsMenu::_on_level_event ", event)
	level_event.emit(event)


func _click_block_menu(button: TextureButton):
	selected_button = button


func _on_test_pressed():
	editor._on_test_pressed()


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)
