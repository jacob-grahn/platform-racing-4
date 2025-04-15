extends Control

@export var usertext_font = "res://fonts/Poetsen_One/PoetsenOne-Regular.ttf"

var isMoving : bool = false
var isResizing : bool = false
var isRotating : bool = false
var buttonSize = 64

var textRotation = 0

var usertext_bg = StyleBoxFlat.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$UserText.set("theme_override_styles/normal", usertext_bg)
	$UserText.context_menu_enabled = false
	enable_text_edits()


func set_usertext_properties(text, text_font, text_size):
	$UserText.text = text
	usertext_font = text_font
	$UserText.set("theme_override_fonts/font", load(text_font))
	$UserText.set("theme_override_font_sizes/font_size", text_size)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if isMoving:
		self.global_position = get_global_mouse_position() + Vector2(buttonSize/2.0, buttonSize/2.0)
	if isResizing:
		resize_text(get_local_mouse_position().x - buttonSize/2.0, get_local_mouse_position().y - buttonSize/2.0)
	if isRotating:
		textRotation = atan2(get_global_mouse_position().y - self.global_position.y, get_global_mouse_position().x - self.global_position.x)
		if Input.is_action_pressed("shift"):
			textRotation = snapped(textRotation, PI/12) #15 degree increments
		self.rotation = textRotation


func resize_text(width, height):
	$UserText.size.x = max(width, 64)
	$UserText.size.y = max(height, 64)
	
	$TextModifierButtons/RotateTextButton.position.x = ($UserText.size.x - buttonSize) / 2.0
	
	$TextModifierButtons/DeleteTextButton.position.x = $UserText.size.x
	
	$TextModifierButtons/ResizeTextButton.position.x = $UserText.size.x
	$TextModifierButtons/ResizeTextButton.position.y = $UserText.size.y


func _on_move_text_button_button_down():
	isMoving = true


func _on_move_text_button_button_up():
	isMoving = false


func _on_resize_text_button_button_down():
	isResizing = true


func _on_resize_text_button_button_up():
	isResizing = false


func _on_rotate_text_button_button_down() -> void:
	isRotating = true


func _on_rotate_text_button_button_up() -> void:
	isRotating = false


func _on_delete_text_button_button_up():
	self.queue_free()


func _on_user_text_focus_entered():
	enable_text_edits()


func _on_user_text_focus_exited():
	disable_text_edits()


func _on_move_text_button_focus_entered():
	enable_text_edits()


func _on_move_text_button_focus_exited():
	disable_text_edits()


func _on_delete_text_button_focus_entered():
	enable_text_edits()


func _on_delete_text_button_focus_exited():
	disable_text_edits()


func _on_resize_text_button_focus_entered():
	enable_text_edits()


func _on_resize_text_button_focus_exited():
	disable_text_edits()


func _on_rotate_text_button_focus_entered() -> void:
	enable_text_edits()


func _on_rotate_text_button_focus_exited() -> void:
	disable_text_edits()


func enable_text_edits():
	usertext_bg.set_bg_color(Color(0.2, 0.2, 0.2, 0.5))
	for button in $TextModifierButtons.get_children():
		button.set_disabled(false)
		button.set_visible(true)


func disable_text_edits():
	usertext_bg.set_bg_color(Color(1.0, 1.0, 1.0, 0.0))
	for button in $TextModifierButtons.get_children():
		button.set_disabled(true)
		button.set_visible(false)
