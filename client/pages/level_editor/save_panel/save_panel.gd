extends Control

@onready var save_button = $SaveButton
@onready var back_button: Button = $BackButton
@onready var title_edit: TextEdit = $TitleEdit
@onready var publish_check_box: CheckBox = $PublishCheckBox
@onready var http_request: HTTPRequest = $HTTPRequest

static var current_level: Dictionary
var is_publish = true

func _ready():
	self.visible = false

func initialize(current_level: Dictionary) -> void:
	self.visible = true

	title_edit.text = Helpers._get_current_level_name()
	back_button.connect("pressed", _back_pressed)
	save_button.connect("pressed", func() -> void:
		_save_pressed(current_level)
	)

func close() -> void:
	self.visible = false

func _back_pressed():
	self.visible = false

func _save_pressed(current_level: Dictionary):
	if title_edit.text == "":
		return
	
	var encoded_string = Helpers._save_to_file(LevelEditor.current_level, title_edit.text)
	
	var post_data = {
		"level_data": encoded_string,
		"level_name": title_edit.text,
	}

	var json_string = JSON.stringify(post_data)
	var url = Helpers.get_base_url() + "/save_level"

	if is_publish:
		var error = $HTTPRequest.request(url, [], HTTPClient.METHOD_POST, json_string)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	
	self.visible = false

func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Failed to save level. Result: ", result)
		return

	if response_code == 200:
		print("Level saved successfully!")
	else:
		print("Error saving level. Server responded with code: ", response_code)


func _on_publish_check_box_toggled(toggled_on: bool) -> void:
	is_publish = toggled_on
