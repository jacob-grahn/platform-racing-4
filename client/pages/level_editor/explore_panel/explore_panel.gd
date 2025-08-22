extends Node2D

signal explore_load

const EXPLORE_ROW = preload("res://pages/level_editor/load_panel/load_row.tscn")
var selected_level_id = ""

@onready var row_holder = $ScrollContainer/RowHolder
@onready var close_button = $CloseButton
@onready var load_button = $LoadButton
@onready var http_request = $HTTPRequest

func _ready():
	close_button.pressed.connect(_close_pressed)
	load_button.pressed.connect(_load_pressed)
	http_request.request_completed.connect(_on_request_completed)
	self.visible = false
	
func initialize() -> void:
	var error = http_request.request(ApiManager.get_base_url() + "/levels")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	else:
		self.visible = true
	
func close() -> void:
	self.visible = false

func render(levels: Array) -> void:
	clear()
	for level_data in levels:
		var level_name = level_data["level_name"]
		var row = EXPLORE_ROW.instantiate()
		row.size.x = 400
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("LevelLabel").text = level_name
		row_holder.add_child(row)
		var button = row.get_node("Button")
		button.pressed.connect(_row_pressed.bind(level_data["id"]))
		if selected_level_id == level_data["id"]:
			button.button_pressed = true

func _on_request_completed(result, response_code, headers, body):
	if result != OK or response_code != 200:
		push_error("Failed to fetch levels.")
		return
	
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if response.size() == 0:
		print("No levels to load.")
		return
	
	render(response)
	
func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()

func _close_pressed():
	self.visible = false
		
func _load_pressed():
	emit_signal("explore_load", selected_level_id)

func _row_pressed(level_id: String):
	selected_level_id = level_id
