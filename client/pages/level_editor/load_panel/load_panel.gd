extends Node2D

signal level_load

const LOAD_ROW = preload("res://pages/level_editor/load_panel/load_row.tscn")
var selected_level = ""

@onready var row_holder = $ScrollContainer/RowHolder
@onready var close_button = $CloseButton
@onready var load_button = $LoadButton
@onready var delete_button = $DeleteButton


func _ready():
	close_button.pressed.connect(_close_pressed)
	load_button.pressed.connect(_load_pressed)
	delete_button.pressed.connect(_delete_pressed)
	render()
	self.visible = false
	
func initialize() -> void:
	render()
	self.visible = true
	
func close() -> void:
	self.visible = false

func render() -> void:
	clear()
	
	var save_level_array = Globals.Helpers._list_saved_levels()
	for level_name in save_level_array:
		var row = LOAD_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("Label").text = level_name
		row_holder.add_child(row)
		var button = row.get_node("Button")
		button.pressed.connect(_row_pressed.bind(level_name))
		if Globals.Helpers._get_current_level_name() == level_name:
			button.button_pressed = true

func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()

func _close_pressed():
	self.visible = false
		
func _load_pressed():
	emit_signal("level_load", selected_level)

func _delete_pressed():
	if selected_level == "":
		return
		
	Globals.Helpers._delete_level(selected_level)
	for child in row_holder.get_children():
		var label = child.get_node("Label")
		if label.text == selected_level:
			child.queue_free()
			break
			
	selected_level = ""

func _row_pressed(level_name: String):
	selected_level = level_name
