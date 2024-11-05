extends Node2D

signal explore_load

const NOW_EDITING_ROW = preload("res://pages/editor/now_editing_panel/NowEditingRow.tscn")
var room_id = ""
var is_live_editing = false
var is_host = false
var member_id_list: Array[String] = []

@onready var row_holder = $ScrollContainer/RowHolder
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var RoomEdit = $RoomEdit
@onready var http_request = $HTTPRequest
@onready var host_edit_panel = $"../HostEditPanel"
@onready var join_edit_panel = $"../JoinEditPanel"
@onready var offline_label: Label = $OfflineLabel

func _ready():
	host_button.pressed.connect(_host_pressed)
	join_button.pressed.connect(_join_pressed)
	
func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()
		
func _host_pressed():
	host_edit_panel.initialize()
	
func _join_pressed():
	join_edit_panel.initialize()
	
func join_room(room: String, member_id_list_input: Array[String], host_id: String):
	RoomEdit.text = room
	host_button.disabled = true
	join_button.disabled = true
	offline_label.visible = false
	member_id_list = member_id_list_input
	render(member_id_list, host_id)
	
func add_member(member_id: String):
	if member_id in member_id_list:
		return
		
	member_id_list.append(member_id)
	var row = NOW_EDITING_ROW.instantiate()
	row.position.y = row_holder.get_child_count() * 50
	row.get_node("Label").text = member_id
	row_holder.add_child(row)

func render(member_id_list: Array[String], host_id: String) -> void:
	clear()
	
	var host_row = NOW_EDITING_ROW.instantiate()
	host_row.position.y = row_holder.get_child_count() * 50
	host_row.get_node("Label").text = host_id + "(HOST)"
	var button = host_row.get_node("Button")
	button.button_pressed = true
	row_holder.add_child(host_row)
	
	for member_id in member_id_list:
		if member_id == host_id:
			continue
			
		var row = NOW_EDITING_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("Label").text = member_id
		row_holder.add_child(row)
