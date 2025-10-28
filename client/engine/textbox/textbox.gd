extends Control

@export var action_man_font = "res://fonts/Action_Man/Action-Man.ttf"
@export var arial_font = "res://fonts/Arial/Arial.ttf"
@export var gwibble_font = "res://fonts/Gwibble/Gwibble.ttf"
@export var poetsenone_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"
@export var quicksand_font = "res://fonts/Quicksand/Quicksand-VariableFont_wght.ttf"
@export var verdana_font = "res://fonts/Verdana/Verdana.ttf"
@export var text_font = poetsenone_font
@onready var label_text = $LabelText
@onready var selected_text_rect = $SelectedTextRect
@onready var edit_text_color_rect = $EditTextColorRect
@onready var edit_text_rect = $EditTextRect
@onready var edit_text = $EditText
@onready var text_modifier_buttons = $TextModifierButtons
@onready var delete_button = $TextModifierButtons/DeleteTextButton
@onready var font_button = $TextModifierButtons/TextFontButton
@onready var font_dropdown_button: OptionButton = $TextModifierButtons/TextFontButton/FontDropdownButton
@onready var resize_button = $TextModifierButtons/ResizeTextButton
@onready var edit_button = $TextModifierButtons/EditTextButton
@onready var rotate_button = $TextModifierButtons/RotateTextButton
@onready var color_button = $TextModifierButtons/ColorTextButton
@onready var move_text_button = $MoveTextButton

var actiontype : String = "null"
var old_position : Vector2
var old_scale : Vector2
var old_mouse_position : Vector2
var buttonSize = 32
var textRotation = 0
var edit_text_bg = StyleBoxFlat.new()
var font_list = {
	"poetsenone": {
		"title": "Poetsen One",
		"font": poetsenone_font
	},
	"arial": {
		"title": "Arial",
		"font": arial_font
	},
	"verdana": {
		"title": "Verdana",
		"font": verdana_font
	},
	"actionman": {
		"title": "Action Man",
		"font": action_man_font
	},
	"gwibble": {
		"title": "Gwibble",
		"font": gwibble_font
	},
	"quicksand": {
		"title": "Quicksand",
		"font": quicksand_font
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	delete_button.connect("button_down", _delete_text)
	for slug in font_list:
		var font_info = font_list[slug]
		var label = font_list[slug].title
		font_dropdown_button.add_item(label)
		font_dropdown_button.set_item_metadata(font_dropdown_button.item_count - 1, font_list[slug].font)
	font_dropdown_button.item_selected.connect(_change_text_font)
	resize_button.connect("button_down", _scale_text)
	edit_button.connect("pressed", _edit_text)
	rotate_button.connect("button_down", _rotate_text)
	color_button.connect("pressed", _change_text_color)
	move_text_button.connect("button_down", _move_text)
	self.connect("focus_exited", disable_text_edits)
	edit_text.set("theme_override_styles/normal", edit_text_bg)
	edit_text.context_menu_enabled = false
	edit_text_bg.set_bg_color(Color(1.0, 1.0, 1.0, 0.0))


func set_text_properties(text, font, font_size, text_size, just_spawned: bool):
	edit_text.text = text
	text_font = font
	edit_text.size = text_size
	edit_text.set("theme_override_fonts/font", load(font))
	edit_text.set("theme_override_font_sizes/font_size", font_size)
	label_text.set("theme_override_fonts/normal_font", load(font))
	label_text.set("theme_override_font_sizes/normal_font_size", font_size)
	if just_spawned:
		_edit_text()
	update_display()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	check_for_button_presses()
	check_focus()
	if actiontype == "deleting":
		self.queue_free()
	if actiontype == "moving":
		var position_x: float = get_global_mouse_position().x - old_mouse_position.x
		var position_y: float = get_global_mouse_position().y - old_mouse_position.y
		self.position = Vector2(old_position.x + position_x, old_position.y + position_y)
	if actiontype == "resizing":
		var scale_x: float = old_scale.x / (old_mouse_position.x / get_local_mouse_position().x)
		var scale_y: float = old_scale.y / (old_mouse_position.y / get_local_mouse_position().y)
		if Input.is_action_pressed("shift"):
			if scale_x >= scale_y:
				resize_text(scale_x, scale_x)
			else:
				resize_text(scale_y, scale_y)
		else:
			resize_text(scale_x, scale_y)
	if actiontype == "rotating":
		textRotation = atan2(get_global_mouse_position().y - self.global_position.y, get_global_mouse_position().x - self.global_position.x)
		if Input.is_action_pressed("shift"):
			textRotation = snapped(textRotation, PI/12) #15 degree increments
		self.rotation = textRotation
	update_display()

func _delete_text():
	actiontype = "deleting"
	self.queue_free()

func _change_text_font(index: int) -> void:
	actiontype = "font"
	edit_text.set("theme_override_fonts/font", load(font_dropdown_button.get_item_metadata(index)))
	label_text.set("theme_override_fonts/normal_font", load(font_dropdown_button.get_item_metadata(index)))
	text_font = edit_text.get("theme_override_font_sizes/font")
	label_text.size = edit_text.size
	label_text.scale = edit_text.scale
	update_display()

func _scale_text():
	if actiontype != "resizing":
		old_scale = edit_text.scale
		old_mouse_position = get_local_mouse_position()
	actiontype = "resizing"

func _move_text():
	if actiontype != "moving":
		old_position = edit_text.global_position
		old_mouse_position = get_global_mouse_position()
	actiontype = "moving"

func _edit_text():
	actiontype = "typing"
	edit_text.grab_focus()

func _rotate_text() -> void:
	actiontype = "rotating"

func _change_text_color() -> void:
	actiontype = "color"

func check_for_button_presses():
	var button_is_pressed = false
	for button in text_modifier_buttons.get_children():
		if button.is_pressed():
			button_is_pressed = true
	if move_text_button.is_pressed():
		button_is_pressed = true
	if font_dropdown_button.is_pressed():
		button_is_pressed = true
	if !edit_text.has_focus() and !button_is_pressed:
		actiontype = ""

func check_focus():
	var is_focused = false
	for button in text_modifier_buttons.get_children():
		if button.has_focus():
			is_focused = true
	if edit_text.has_focus() or move_text_button.has_focus() or font_dropdown_button.has_focus():
		is_focused = true
	if is_focused:
		enable_text_edits()
		if actiontype != "typing":
			selected_text_rect.visible = true
			edit_button.visible = true
		else:
			edit_button.visible = false
			selected_text_rect.visible = false
	else:
		disable_text_edits()
		selected_text_rect.visible = false
		if edit_text.text == "":
			actiontype = "deleting"

func enable_text_edits():
	for button in text_modifier_buttons.get_children():
		button.set_disabled(false)
		button.set_visible(true)


func disable_text_edits():
	for button in text_modifier_buttons.get_children():
		button.set_disabled(true)
		button.set_visible(false)

func update_display():
	if actiontype == "typing":
		move_text_button.visible = false
		label_text.visible = false
		edit_text_color_rect.visible = true
		edit_text_rect.visible = true
		edit_text.visible = true
		edit_text.editable = true
	else:
		label_text.visible = true
		edit_text_color_rect.visible = false
		edit_text_rect.visible = false
		edit_text.editable = false
		edit_text.visible = false
		move_text_button.visible = true
	label_text.text = edit_text.text
	label_text.size = edit_text.size
	label_text.scale = edit_text.scale
	selected_text_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
	selected_text_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
	edit_text_color_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
	edit_text_color_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
	edit_text_rect.size = Vector2(edit_text.size.x * abs(edit_text.scale.x), edit_text.size.y * abs(edit_text.scale.y))
	edit_text_rect.scale = Vector2(abs(edit_text.scale.x) / edit_text.scale.x, abs(edit_text.scale.y) / edit_text.scale.y)
	delete_button.position = Vector2(-buttonSize / 2, (edit_text.size.y * edit_text.scale.y) - (buttonSize / 2))
	font_button.position = Vector2((((edit_text.size.x * edit_text.scale.x) / 2) - (buttonSize / 2)), (edit_text.size.y * edit_text.scale.y) - (buttonSize / 2))
	font_button.position = Vector2((((edit_text.size.x * edit_text.scale.x) / 2) - (buttonSize / 2)), (edit_text.size.y * edit_text.scale.y) - (buttonSize / 2))
	resize_button.position = Vector2((edit_text.size.x * edit_text.scale.x) - (buttonSize / 2), (edit_text.size.y * edit_text.scale.y) - (buttonSize / 2))
	edit_button.position = Vector2(-buttonSize / 2, -buttonSize / 2)
	rotate_button.position = Vector2((((edit_text.size.x * edit_text.scale.x) / 2) - (buttonSize / 2)), -buttonSize / 2)
	color_button.position = Vector2((edit_text.size.x * edit_text.scale.x) - (buttonSize / 2), -buttonSize / 2)
	move_text_button.size = edit_text.size
	move_text_button.scale = edit_text.scale

func resize_text(width, height):
	edit_text.scale.x = width
	edit_text.scale.y = height
	label_text.scale = edit_text.scale
