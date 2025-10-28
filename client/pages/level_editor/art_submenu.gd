extends Control

signal control_event
signal level_event

@onready var color_box = preload("res://ui/colorbutton.tscn")
@onready var art_menu = $ArtMenu
@onready var selection_glow = $ArtMenu/SelectionGlow
@onready var background_button = $ArtMenu/BackgroundBox/Button
@onready var brush_button = $ArtMenu/BrushBox/TextureButton
@onready var eraser_button = $ArtMenu/EraserBox/TextureButton
@onready var stamp_button = $ArtMenu/StampBox/TextureButton
@onready var text_button = $ArtMenu/TextBox/TextureButton
@onready var art_settings = $ArtSettings
@onready var art_settings_panel = $ArtSettings/ArtSettingsPanel
@onready var color_box_button = $ArtSettings/ColorBox
@onready var color_picker_texture = $ArtSettings/ColorBox/TextureButton/ColorPicker
@onready var color_picker_colorin = $ArtSettings/ColorBox/TextureButton/ColorPickerColorin
@onready var stamp_texture = $ArtSettings/SelectedStampBox/StampTexture
@onready var selected_stamp_box = $ArtSettings/SelectedStampBox
@onready var selected_stamp_button = $ArtSettings/SelectedStampBox/Button
@onready var size_box = $ArtSettings/SizeBox
@onready var size_text = $ArtSettings/SizeBox/SizeText
@onready var size_button = $ArtSettings/SizeBox/Button
@onready var alpha_box = $ArtSettings/AlphaBox
@onready var alpha_label = $ArtSettings/AlphaBox/AlphaLabel
@onready var alpha_text = $ArtSettings/AlphaBox/AlphaText
@onready var rotation_box = $ArtSettings/RotationBox
@onready var rotation_label = $ArtSettings/RotationBox/RotationLabel
@onready var rotation_text = $ArtSettings/RotationBox/RotationText
@onready var art_popup = $ArtPopup
@onready var art_popup_panel = $ArtPopup/ArtPopupPanel
@onready var layer_panel = $LayerPanel
var active: bool = false
var layers: Node2D
var editor_events: EditorEvents
var background_graphics: Array = []
var background_array: Array = []
var stamp_graphics: Array = []
var stamp_array: Array = []
var selected_button: TextureButton
var dont_change_color_list: Array = ["ColorBox", "SelectedStampBox", "SizeBox", "AlphaBox", "RotationBox", "BackgroundBox", "BGButtonContainer"]
var bg_id: String
var bg_color: Color = Color("BBBBDDFF")
var brush_color: Color = Color("000000FF")
var brush_alpha: float = 100
var text_color: Color = Color("071E6BFF")

func _ready() -> void:
	var bg_container: Backgrounds = Backgrounds.new()
	background_graphics = bg_container.bg_graphic_list
	background_array = bg_container.bg_list
	var stamp_container: Stamps = Stamps.new()
	stamp_graphics = stamp_container.stamp_graphic_list
	stamp_array = stamp_container.stamp_list
	background_button.pressed.connect(_show_art_popup.bind(background_button))
	brush_button.pressed.connect(_click_art_menu.bind(brush_button))
	eraser_button.pressed.connect(_click_art_menu.bind(eraser_button))
	stamp_button.pressed.connect(_click_art_menu.bind(stamp_button))
	text_button.pressed.connect(_click_art_menu.bind(text_button))
	selected_stamp_button.pressed.connect(_show_art_popup.bind(selected_stamp_button))
	_click_art_menu(brush_button)


func init() -> void:
	layer_panel.init(layers, "art")
	editor_events.connect_to([layer_panel])


func deactivate():
	active = false


func activate():
	emit_signal("control_event", {
		"type": EditorEvents.SELECT_TOOL,
		"tool": "draw"
	})
	active = true


func _physics_process(delta: float) -> void:
	if active:
		visible = true
		for child in art_menu.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		for child in art_settings.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
		for child in art_popup.get_children():
			for node in child.get_children():
				_check_clicked_button(node)
	
		if selected_button:
			set_selection_glow()
	else:
		visible = false


func _check_clicked_button(node: Node):
	var color1: Color
	var color2: Color
	if node.get_parent().name == "BrushBox":
		color1 = Color("7f7f7f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "EraserBox":
		color1 = Color("eb8a9f")
		color2 = Color("ffffff")
	elif node.get_parent().name == "StampBox":
		color1 = Color("be8b61")
		color2 = Color("ffffff")
	elif node.get_parent().name == "TextBox":
		color1 = Color("071e6b")
		color2 = Color("ffffff")
	if node.get_parent().name != "ColorBox" and (node is TextureButton or node is Button):
		if node.visible and node.is_hovered() and !node.is_pressed():
			if node.get_parent().name != "BGButtonContainer":
				node.get_parent().scale = Vector2(1.25, 1.25)
			else:
				node.scale = Vector2(1.25, 1.25)
		else:
			if node.get_parent().name != "BGButtonContainer":
				node.get_parent().scale = Vector2(1, 1)
			else:
				node.scale = Vector2(1, 1)
		if node.get_parent().name not in dont_change_color_list:
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color2
			else:
				node.self_modulate = color1
	elif node is ColorRect:
		if node.get_parent().name not in dont_change_color_list:
			if selected_button.get_parent() == node.get_parent():
				node.self_modulate = color1
			else:
				node.self_modulate = color2


func _show_art_popup(button: Button):
	if art_popup.get_child_count() > 1:
		for child in art_popup.get_children():
			if child is not Panel:
				child.free()
	if !art_popup.visible:
		art_popup.visible = true
	if button == background_button or button == selected_stamp_button:
		var graphicbuttoncontainer = Control.new()
		graphicbuttoncontainer.name = "BGButtonContainer"
		art_popup.add_child(graphicbuttoncontainer)
		var graphic_array: Array
		var total_size: int
		var xoffset: float
		var yoffset: float
		if button == background_button:
			art_popup.position = Vector2((art_menu.size.x + art_menu.global_position.x) + 10, art_menu.global_position.y)
			graphic_array = background_graphics
			total_size = graphic_array.size() + 1
			xoffset = art_menu.global_position.x + background_button.global_position.x
			yoffset = art_menu.global_position.y + background_button.global_position.y
		else:
			art_popup.position = Vector2((art_settings.size.x + art_settings.global_position.x) + 10, art_settings.global_position.y)
			graphic_array = stamp_array
			total_size = graphic_array.size()
			xoffset = art_settings.global_position.x + selected_stamp_button.global_position.x
			yoffset = art_settings.global_position.y + selected_stamp_button.global_position.y
		for graphic in total_size:
			if graphic >= graphic_array.size():
				var bg_color_button = color_box.instantiate()
				bg_color_button.size = Vector2(48, 48)
				bg_color_button.position = Vector2(20 + (68 * snapped((graphic % 5), 1)), 20 + (68 * snapped((graphic / 5), 1)))
				bg_color_button.name = "ColorBox"
				bg_color_button.spawn_x = art_popup.position.x + bg_color_button.size.x
				art_popup.add_child(bg_color_button)
				bg_color_button.set_color(bg_color)
				bg_color_button.colorbutton_color_changed.connect(_set_bg.bind())
			else:
				var graphicbutton = TextureButton.new()
				graphicbutton.texture_normal = graphic_array[graphic]
				graphicbutton.ignore_texture_size = true
				if button == selected_stamp_button:
					graphicbutton.stretch_mode = 5
				else:
					graphicbutton.stretch_mode = 0
				graphicbutton.size = Vector2(48, 48)
				graphicbutton.position = Vector2(20 + (68 * snapped((graphic % 5), 1)), 20 + (68 * snapped((graphic / 5), 1)))
				graphicbutton.name = "BGButton" + str(graphic)
				graphicbuttoncontainer.add_child(graphicbutton)
				if button == background_button:
					graphicbutton.pressed.connect(_set_bg.bind(Color("FFFFFF"), background_array[graphic]))
			if graphic < 5:
				art_popup.size = Vector2(20 + (68 * (snapped((graphic % 5), 1) + 1)), 20 + (68 * (snapped((graphic / 5), 1) + 1)))
			else:
				art_popup.size = Vector2(360, 20 + (68 * (snapped((graphic / 5), 1) + 1)))
			art_popup_panel.size = art_popup.size
			graphicbuttoncontainer.size = art_popup.size


func _set_bg(new_color: Color = "FFFFFF", id: String = "blank"):
	bg_color = new_color
	bg_id = id
	emit_signal("level_event", {
		"type": EditorEvents.SET_BACKGROUND,
		"bg": bg_id,
		"fade_color": bg_color.to_html(false)
	})
	art_popup.hide()


func _set_brush_color(new_color: Color):
	brush_color = new_color
	emit_signal("control_event", {
		"type": EditorEvents.SET_BRUSH_COLOR,
		"color": brush_color.to_html(true) # Include alpha in hex format (e.g. FFFFFFFF)
	})


func _set_brush_alpha(new_alpha: int):
	brush_alpha = new_alpha
	emit_signal("control_event", {
		"type": EditorEvents.SET_BRUSH_ALPHA,
		"alpha": float(brush_alpha) / 100
	})


func _set_brush_size(new_size: int):
	emit_signal("control_event", {
		"type": EditorEvents.SET_BRUSH_SIZE,
		"size": new_size
	})


func _set_text_color(new_color: Color):
	text_color = new_color


func disconnect_button(button):
	for child in button.get_children():
		if child is Button:
			if child.is_connected("colorbutton_color_changed", _set_brush_color.bind()):
				child.disconnect("colorbutton_color_changed", _set_brush_color.bind())
			if child.is_connected("colorbutton_color_changed", _set_text_color.bind()):
				child.disconnect("colorbutton_color_changed", _set_text_color.bind())
			if child.is_connected("slider_value_changed", _set_brush_size.bind()):
				child.disconnect("slider_value_changed", _set_brush_size.bind())
			if child.is_connected("slider_value_changed", _set_brush_alpha.bind()):
				child.disconnect("slider_value_changed", _set_brush_alpha.bind())


func _click_art_menu(button: TextureButton):
	selected_button = button
	var tool_id: String = ""
	color_box_button.visible = false
	disconnect_button(color_box_button)
	disconnect_button(size_box)
	selected_stamp_box.visible = false
	size_box.visible = false
	alpha_box.visible = false
	rotation_box.visible = false
	if selected_button == brush_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_ART_MODE,
			"mode": "draw"
		})
		color_box_button.visible = true
		color_box_button.position = Vector2(20, 20)
		color_box_button.spawn_x = color_box_button.size.x
		color_box_button.set_color(brush_color)
		color_box_button.connect("colorbutton_color_changed", _set_brush_color.bind())
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		size_box.spawn_x = size_box.size.x + 10
		size_box.set_button("Size", 5, 1, 200)
		size_box.connect("slider_value_changed", _set_brush_size.bind())
		alpha_box.visible = true
		alpha_box.position = Vector2(20, 156)
		alpha_box.spawn_x = alpha_box.size.x + 10
		alpha_box.set_button("Alpha", 100, 0, 100)
		alpha_box.connect("slider_value_changed", _set_brush_alpha.bind())
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)
	elif selected_button == eraser_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_ART_MODE,
			"mode": "erase"
		})
		size_box.visible = true
		size_box.position = Vector2(20, 20)
		alpha_box.visible = true
		alpha_box.position = Vector2(20, 88)
		art_settings_panel.size = Vector2(88, 156)
		art_settings.size = Vector2(98, 166)
	elif selected_button == stamp_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_ART_MODE,
			"mode": "stamp"
		})
		selected_stamp_box.visible = true
		selected_stamp_box.position = Vector2(20, 20)
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		rotation_box.visible = true
		rotation_box.position = Vector2(20, 156)
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)
	elif selected_button == text_button:
		emit_signal("control_event", {
			"type": EditorEvents.SELECT_ART_MODE,
			"mode": "text"
		})
		color_box_button.visible = true
		color_box_button.position = Vector2(20, 20)
		color_box_button.spawn_x = color_box_button.size.x
		color_box_button.set_color(text_color)
		color_box_button.connect("colorbutton_color_changed", _set_text_color.bind())
		size_box.visible = true
		size_box.position = Vector2(20, 88)
		rotation_box.visible = true
		rotation_box.position = Vector2(20, 156)
		art_settings_panel.size = Vector2(88, 224)
		art_settings.size = Vector2(98, 234)

func set_selection_glow():
	selection_glow.size = (selected_button.get_parent().size * selected_button.get_parent().scale) + Vector2(10, 10)
	selection_glow.global_position = selected_button.get_parent().global_position - Vector2(5, 5)
