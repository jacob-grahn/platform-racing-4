extends Control

signal set_page

@onready var holder = $Holder
@onready var button_solely_for_focus_button = $Holder/ButtonSolelyForFocus
@onready var left_button = $Holder/LeftButton
@onready var numbered_pages_button = $Holder/NumberedPagesButtons
@onready var go_to_page_popup = $Holder/GoToPagePopup
@onready var go_to_page = $Holder/GoToPagePopup/GoToPage
@onready var right_button = $Holder/RightButton

var cursor_page: int = 1
var total_pages: int = 3
var max_buttons: int = 3
var allow_go_to_page: bool = true
var align: String = "left"
var padding: int = 10

func _ready():
	left_button.pressed.connect(_set_page.bind(true, -1))
	go_to_page.connect("set_navagation_page", _on_set_page)
	right_button.pressed.connect(_set_page.bind(true, 1))

func init(page: int, pages: int, buttons: int, allow: bool):
	cursor_page = page
	total_pages = pages
	max_buttons = buttons
	allow_go_to_page = allow
	left_button.visible = true
	numbered_pages_button.visible = true
	right_button.visible = true
	update_display()

func set_align(new_align: String):
	align = new_align

func update_display():
	for old_button in numbered_pages_button.get_children():
		if old_button.is_connected("pressed", _set_page):
			old_button.disconnect("pressed", _set_page)
		if old_button.is_connected("pressed", _show_popup):
			old_button.disconnect("pressed", _show_popup)
		old_button.queue_free()
	var increment: int = 0
	var max_elements: int = max_buttons
	if max_buttons > total_pages:
		max_elements = total_pages
	var min: int = floor(max_elements / 2)
	var max: int = total_pages - (max_elements - floor(max_elements / 2))
	if cursor_page >= max:
		increment = (total_pages - max_elements)
	elif cursor_page <= min:
		increment = 0
	else:
		increment = (cursor_page - floor(max_elements / 2))
	left_button.disabled = true
	right_button.disabled = true
	if cursor_page > 1:
		left_button.disabled = false
	if cursor_page < total_pages:
		right_button.disabled = false
	numbered_pages_button.position.x = left_button.position.x + left_button.size.x + padding
	numbered_pages_button.size.x = padding
	for button in max_elements:
		increment += 1
		var newbutton = Button.new()
		newbutton.disabled = true
		if total_pages > 1 and increment > 0:
			newbutton.disabled = false
		newbutton.size = Vector2(48, 38)
		newbutton.set("theme_override_font_sizes/font_size", 22)
		newbutton.position.x = (newbutton.size.x + padding) * button
		numbered_pages_button.size.x += newbutton.size.x + padding
		if allow_go_to_page and button >= (max_elements - 1) and max_elements > 1 and total_pages > max_elements and cursor_page < max:
			newbutton.text = ". . ."
			newbutton.pressed.connect(_show_popup.bind(newbutton.position.x, newbutton.size.y + newbutton.position.y))
		else:
			newbutton.text = str(increment)
			newbutton.pressed.connect(_set_page.bind(false, increment))
		numbered_pages_button.add_child(newbutton)
		if !newbutton.disabled and newbutton.text == str(cursor_page):
			newbutton.self_modulate = Color(1, 1, 0.5, 1)
			newbutton.grab_focus()
		else:
			newbutton.self_modulate = Color(1, 1, 1, 1)
	if increment <= 1:
		button_solely_for_focus_button.grab_focus() # this is so block_submenu doesnt close itself
	if (numbered_pages_button.size.x - (padding * 2)) > 0:
		numbered_pages_button.size.x -= padding * 2
		right_button.position.x = numbered_pages_button.position.x + numbered_pages_button.size.x + padding
	else:
		numbered_pages_button.size.x = 0
		right_button.position.x = left_button.position.x + left_button.size.x + padding
	holder.size = Vector2(right_button.position.x + right_button.size.x, right_button.size.y)
	if align == "right":
		holder.position.x = -holder.size.x
	else:
		holder.position.x = 0
func _set_page(incordec: bool, new_cursor_page: int):
	if incordec:
		cursor_page += new_cursor_page
	else:
		cursor_page = new_cursor_page
	emit_signal("set_page", cursor_page)
	update_display()

func _show_popup(spawn_x: int, spawn_y: int):
	go_to_page_popup.popup(Rect2i(holder.global_position.x + spawn_x, holder.global_position.y + spawn_y, 380, 64))
	go_to_page.init(total_pages, cursor_page)

func _on_set_page(new_page_number: int):
	_set_page(false, clamp(new_page_number, 1, total_pages))
	go_to_page_popup.visible = false

func check_focus() -> bool:
	var has_focus: bool = false
	if button_solely_for_focus_button.has_focus():
		has_focus = true
	if left_button.has_focus():
		has_focus = true
	for child in numbered_pages_button.get_children():
		if child.has_focus():
			has_focus = true
	if go_to_page_popup.has_focus() or go_to_page.has_focus():
		has_focus = true
	if right_button.has_focus():
		has_focus = true
	return has_focus
