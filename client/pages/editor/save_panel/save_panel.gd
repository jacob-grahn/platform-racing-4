extends Control

@onready var save_button = $SaveButton
@onready var back_button: Button = $BackButton
@onready var title_edit: TextEdit = $TitleEdit

static var current_level: Dictionary

func _ready():
	self.visible = false
	
func initialize(current_level: Dictionary) -> void:
	self.visible = true
	
	title_edit.text = Helpers._get_current_level_name()
	back_button.connect("pressed", _back_pressed)
	save_button.connect("pressed", func() -> void:
		_save_pressed(current_level)
	)

func _back_pressed():
	self.visible = false
	
func _save_pressed(current_level: Dictionary):
	if (title_edit.text == ""):
		return
		
	Helpers._save_to_file(Editor.current_level, title_edit.text)
	self.visible = false
