extends TabBar

signal level_load

const LEVEL_ROW = preload("res://pages/level_lists/level_panel/LevelRow.tscn")
var selected_level_id = 0
var current_page: int = 1

@onready var row_holder = $ScrollContainer/RowHolder
@onready var load_button = $LoadButton
@onready var title_label = $TitleLabel

@export var level_tab_name: String = "campaign"

func _ready():
	title_label.text = get_tab(level_tab_name)
	load_button.pressed.connect(_load_pressed)
	$HTTPRequest.request_completed.connect(self._http_request_completed)
	perform_paginated_request()

func get_tab(tab_name: String) -> String:
	match tab_name:
		"campaign":
			return "Campaign"
		"best":
			return "All Time Best"
		"best_week":
			return "Week's Best"
		"newest":
			return "Newest"
	return ""
	
func initialize() -> void:
	self.visible = true
	
func close() -> void:
	self.visible = false

func perform_paginated_request() -> void:
	var url = Helpers.get_base_url() + "/files/lists/" + level_tab_name + "/" + str(current_page)
	var error = $HTTPRequest.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if !response:
		print("No response")
		return

	if response.levels.size() == 0:
		return
	
	render(response.levels)
	current_page += 1
	perform_paginated_request()
	
func render(levels: Array) -> void:
	for level_data in levels:
		var row = LEVEL_ROW.instantiate()
		row_holder.add_child(row)

		row.get_node("RowHolder/TitleLabel").text = "Title: " + level_data["title"]
		row.get_node("RowHolder/UserLabel").text = "By: " + level_data["user_name"]
		row.get_node("RowHolder/RatingLabel").text = "Rating: " + str(level_data["rating"])
		row.get_node("RowHolder/PlaysLabel").text = "Plays: " + str(level_data["play_count"])

		var button = row.get_node("Button")
		button.pressed.connect(_row_pressed.bind(level_data["level_id"]))
		if selected_level_id == level_data["level_id"]:
			button.button_pressed = true

func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()

func _load_pressed():
	if selected_level_id == 0:
		return
		
	Game.pr2_level_id = str(selected_level_id)
	Helpers.set_scene("GAME")
	return
	
func _row_pressed(level_id: int):
	selected_level_id = level_id
