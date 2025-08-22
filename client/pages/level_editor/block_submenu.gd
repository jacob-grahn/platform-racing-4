extends Control

signal control_event

@onready var block_menu = $BlockMenu
@onready var selection_glow = $BlockMenu/SelectionGlow
@onready var block_mover_button = $BlockMenu/BlockMover/TextureButton
@onready var block_killer_button = $BlockMenu/BlockKiller/TextureButton
@onready var block_draw_panel = $BlockMenu/BlockDrawPanel
@onready var block_dropper_button = $BlockMenu/BlockDropper/TextureButton
@onready var block_draw_button = $BlockMenu/BlockDraw/TextureButton
@onready var block_picker = $BlockPicker
@onready var block_container = $BlockPicker/BlockContainer
@onready var tab_bar = $BlockPicker/TabBar
@onready var block_picker_navagation_buttons = $BlockPicker/NavagationButtons
@onready var block_picker_block_row_1 = $BlockPicker/BlockContainer/BlockRow1
@onready var block_picker_block_row_2 = $BlockPicker/BlockContainer/BlockRow2
@onready var block_picker_block_row_3 = $BlockPicker/BlockContainer/BlockRow3
@onready var block_picker_block_row_4 = $BlockPicker/BlockContainer/BlockRow4
@onready var block_picker_block_row_5 = $BlockPicker/BlockContainer/BlockRow5

const STYLE_LIST: Array = [6, 1, 2, 3, 5, 4, 0, 0]
const BLOCK_LIST: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 35, 36, 37, 38, 39, 40, 41, 42, 43]

static var selected_block_id: int
var texture: Texture2D = preload("res://tiles/tileatlas.png")
var selected_button: TextureButton
var block_picker_focused: bool = false
var block_row_list: Array
var current_tab: int

func _ready() -> void:
	block_row_list = [block_picker_block_row_1, block_picker_block_row_2, block_picker_block_row_3, block_picker_block_row_4, block_picker_block_row_5]
	block_mover_button.pressed.connect(_click_block_menu.bind(block_mover_button))
	block_killer_button.pressed.connect(_click_block_menu.bind(block_killer_button))
	block_dropper_button.pressed.connect(_click_block_menu.bind(block_dropper_button))
	selected_block_id = 1
	_set_current_block(selected_block_id, CoordinateUtils.to_atlas_coords(1))
	_update_block_list_display()
	current_tab = tab_bar.current_tab
	block_draw_button.pressed.connect(_show_block_picker)
	_click_block_menu(block_dropper_button)


func _physics_process(delta: float) -> void:
	for child in block_menu.get_children():
		for node in child.get_children():
			_click_button(node)
	if selected_button == block_dropper_button:
		block_draw_panel.visible = true
		block_draw_button.visible = true
	else:
		block_draw_panel.visible = false
		block_draw_button.visible = false
	
	if current_tab != tab_bar.current_tab:
		_update_block_list_display()
	current_tab = tab_bar.current_tab
	
	block_picker_focused = check_block_picker_focus()
	if block_picker_focused:
		for node in block_container.get_children():
			_click_button(node)
	else:
		block_picker.visible = false
		
	
	if selected_button:
		set_selection_glow()


func _update_block_list_display():
	print(tab_bar.current_tab)
	for child in block_container.get_children():
		child.free()
	var block_gap = CoordinateUtils.seperator
	for block in BLOCK_LIST.size():
		var tile_id = BLOCK_LIST[block]
		var true_tile_id = tile_id + (block_gap * STYLE_LIST[tab_bar.current_tab])
		var atlas_coords = CoordinateUtils.to_atlas_coords(true_tile_id)
		var coords = CoordinateUtils.to_atlas_coords(block + 1)
		var new_block_button = TextureButton.new()
		new_block_button.ignore_texture_size = true
		new_block_button.stretch_mode = 0
		new_block_button.texture_normal = AtlasTexture.new()
		new_block_button.texture_normal.atlas = texture
		new_block_button.texture_normal.region = Rect2((128 * atlas_coords.x), (128 * atlas_coords.y), 128, 128)
		new_block_button.size = Vector2(48, 48)
		new_block_button.global_position = Vector2(68 * coords.x, 68 * coords.y)
		new_block_button.name = "BlockButton" + str(block)
		new_block_button.pressed.connect(_set_current_block.bind(tile_id + (100 * STYLE_LIST[tab_bar.current_tab]), atlas_coords))
		block_container.add_child(new_block_button)
		if BLOCK_LIST[block] == 33:
			var default_teleport_color = TextureRect.new()
			var teleport_atlas_coords = CoordinateUtils.to_atlas_coords(34 + (block_gap * STYLE_LIST[tab_bar.current_tab]))
			default_teleport_color.ignore_texture_size = true
			default_teleport_color.stretch_mode = 0
			default_teleport_color.texture = AtlasTexture.new()
			default_teleport_color.texture.atlas = texture
			default_teleport_color.texture.region = Rect2((128 * teleport_atlas_coords.x), (128 * teleport_atlas_coords.y), 128, 128)
			default_teleport_color.size = Vector2(48, 48)
			default_teleport_color.name = "TeleportBlockColor"
			default_teleport_color.self_modulate = Color("E22B2EFF")
			default_teleport_color.show_behind_parent = true
			new_block_button.add_child(default_teleport_color)

func _set_current_block(block_id: float, block_atlas_coords: Vector2) -> void:
	var atlas_coords = block_atlas_coords
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_BLOCK,
		"block_id": block_id
	})
	block_draw_button.texture_normal.region = Rect2((128 * atlas_coords.x), (128 * atlas_coords.y), 128, 128)
	block_picker.visible = false
	block_picker_focused = false

func _click_button(node: Node):
	var color1: Color
	var color2: Color
	if node.get_parent().name == "BlockMover":
		color1 = Color("8d49fa")
		color2 = Color("ffffff")
	elif node.get_parent().name == "BlockKiller":
		color1 = Color("ff5f5f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "BlockDropper":
		color1 = Color("00c05f")
		color2 = Color("ffffff")
	if node is TextureButton:
		if node.visible and node.is_hovered() and !node.is_pressed():
			if node.get_parent().name != "BlockContainer":
				node.get_parent().scale = Vector2(1.25, 1.25)
			else:
				node.scale = Vector2(1.25, 1.25)
		else:
			if node.get_parent().name != "BlockContainer":
				node.get_parent().scale = Vector2(1, 1)
			else:
				node.scale = Vector2(1, 1)
		if node.get_parent().name == "BlockMover" or node.get_parent().name == "BlockKiller" or node.get_parent().name == "BlockDropper":
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color2
			else:
				node.self_modulate = color1
	elif node is ColorRect:
		if selected_button.get_parent() == node.get_parent():
			node.self_modulate = color1
		else:
			node.self_modulate = color2


func _click_block_menu(button: TextureButton):
	var tool_id: String = ""
	selected_button = button
	if selected_button == block_dropper_button:
		tool_id = "blocks"
	elif selected_button == block_killer_button:
		tool_id = "erase"
	if tool_id:
		emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": tool_id
	})


func _show_block_picker():
	block_picker.visible = true
	block_picker.grab_focus()

func check_block_picker_focus() -> bool:
	if block_picker.has_focus():
		return true
	else:
		var block_picker_children_has_focus: bool = false
		for child in block_picker.get_children():
			if child.has_focus():
				block_picker_children_has_focus = true
		for child in block_picker_navagation_buttons.get_children():
			if child.has_focus():
				block_picker_children_has_focus = true
		for child in block_container.get_children():
			if child.has_focus():
				block_picker_children_has_focus = true
		if block_picker_children_has_focus:
			return true
		else:
			return false


func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)
