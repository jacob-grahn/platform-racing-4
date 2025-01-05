extends Node2D

signal explore_load

const NOW_EDITING_ROW = preload("res://pages/editor/now_editing_panel/NowEditingRow.tscn")
var room_id = ""
var is_live_editing = false
var is_host = false
var member_id_list: Array[String] = []

@onready var row_holder = $ScrollContainer/RowHolder
@onready var host_button = $HostButton
@onready var join_quit_button = $JoinQuitButton
@onready var RoomEdit = $RoomEdit
@onready var http_request = $HTTPRequest
@onready var host_edit_panel = $"../HostEditPanel"
@onready var join_edit_panel = $"../JoinEditPanel"
@onready var quit_edit_panel = $"../QuitEditPanel"
@onready var offline_label: Label = $OfflineLabel

func _ready():
	host_button.pressed.connect(_host_pressed)
	join_quit_button.pressed.connect(_join_quit_pressed)
	
func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()
		
func _host_pressed():
	host_edit_panel.initialize()
	
func _join_quit_pressed():
	if is_live_editing:
		quit_edit_panel.initialize(RoomEdit.text)
	else:
		join_edit_panel.initialize()

func quit_room(isMe: bool, member_id_list_input: Array[String], host_id: String):
	if isMe:
		is_live_editing = false
		RoomEdit.text = ""
		host_button.disabled = false
		join_quit_button.text = "Join"
		offline_label.visible = true
		member_id_list = []
		clear()
	else:
		member_id_list = member_id_list_input
		render(member_id_list, host_id)
	
func join_room(room: String, member_id_list_input: Array[String], host_id: String):
	is_live_editing = true
	RoomEdit.text = room
	host_button.disabled = true
	join_quit_button.text = "Quit"
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
	
	if host_id == Session.get_username():
		host_row.get_node("Label").text += "(ME)"
	
	var host_button = host_row.get_node("Button")
	host_button.button_pressed = true
	row_holder.add_child(host_row)
	
	for member_id in member_id_list:
		if member_id == host_id:
			continue
			
		var row = NOW_EDITING_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		
		if member_id == Session.get_username():
			row.get_node("Label").text = member_id + "(ME)"
		else:
			row.get_node("Label").text = member_id
		
		var button = host_row.get_node("Button")
		button.button_pressed = false
		row_holder.add_child(row)
