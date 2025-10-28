extends Control

signal set_navagation_page

@onready var total_pages_text = $TotalPagesText
@onready var page_number_line_edit = $PageNumberLineEdit
@onready var ok_button = $OKButton
@onready var cancel_button = $CancelButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ok_button.connect("pressed", _set_page_number)
	cancel_button.connect("pressed", _hide)
	size = Vector2(345, 125)

func init(max_pages_number: int, current_page_number: int):
	total_pages_text.text = " / " + str(max_pages_number)
	page_number_line_edit.text = str(current_page_number)
	visible = true

func _set_page_number():
	if !page_number_line_edit.text.is_empty() and page_number_line_edit.text.is_valid_int():
		emit_signal("set_navagation_page", int(page_number_line_edit.text))

func _hide():
	if visible:
		visible = false
	if get_parent() is PopupPanel:
		get_parent().visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
