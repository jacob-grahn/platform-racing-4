extends Node2D

signal explore_load

const USERS_ROW = preload("res://pages/level_editor/now_editing_panel/users_row.tscn")
const CHAT_ROW = preload("res://pages/level_editor/now_editing_panel/chat_row.tscn")

var room_id = ""
var is_live_editing = false
var is_host = false
var member_id_list: Array[String] = []

@onready var game_client: Node2D = get_node("/root/Main/GameClient")
@onready var http_request = $HTTPRequest
@onready var users_row_holder = $TabContainer/Users/ScrollContainer/RowHolder
@onready var users_host_button = $TabContainer/Users/HostButton
@onready var users_join_quit_button = $TabContainer/Users/JoinQuitButton
@onready var users_room_edit = $TabContainer/Users/RoomEdit
@onready var users_host_edit_panel = $"../HostEditPanel"
@onready var users_join_edit_panel = $"../JoinEditPanel"
@onready var users_quit_edit_panel = $"../QuitEditPanel"
@onready var users_offline_label: Label = $TabContainer/Users/OfflineLabel

@onready var chat_tab_container = $TabContainer
@onready var chat_unread_dot: Sprite2D = $UnreadDot
@onready var chat_scroll_container = $TabContainer/Chat/ChatScrollContainer
@onready var chat_row_holder = $TabContainer/Chat/ChatScrollContainer/RowHolder
@onready var chat_offline_label: Label = $TabContainer/Chat/OfflineLabel
@onready var chat_message_edit: LineEdit = $TabContainer/Chat/MessageEdit
@onready var chat_send_button: Button = $TabContainer/Chat/SendButton


func _ready():
	users_host_button.pressed.connect(_users_host_pressed)
	users_join_quit_button.pressed.connect(_users_join_quit_pressed)
	chat_send_button.pressed.connect(chat_send_message)
	chat_message_edit.editable = false
	chat_send_button.disabled = true
	chat_unread_dot.hide()


func init(menu) -> void:
	menu.control_event.connect(_on_control_event)


func _on_control_event(event) -> void:
	if event.type == EditorEvents.ENABLE_COLLAB:
		visible = event.value


func quit_room(isMe: bool, quitUserID: String, member_id_list_input: Array[String], host_id: String):
	if isMe:
		is_live_editing = false
		chat_unread_dot.hide()
		users_room_edit.text = ""
		users_host_button.disabled = false
		users_join_quit_button.text = "Join"
		users_offline_label.visible = true
		chat_offline_label.visible = true
		chat_send_button.disabled = true
		chat_message_edit.editable = false
		member_id_list = []
		users_clear()
		chat_clear()
	else:
		member_id_list = member_id_list_input
		users_render(member_id_list, host_id)
		chat_receive_message(quitUserID + " has left the room.")
	
func join_room(room: String, member_id_list_input: Array[String], host_id: String):
	chat_clear()
	is_live_editing = true
	users_room_edit.text = room
	users_host_button.disabled = true
	users_join_quit_button.text = "Quit"
	users_offline_label.visible = false
	chat_offline_label.visible = false
	chat_send_button.disabled = false
	chat_message_edit.editable = true
	member_id_list = member_id_list_input
	users_render(member_id_list, host_id)
	chat_receive_message("You(" + Globals.Session.get_username() + ") have joined the room.")

func add_member(member_id: String):
	if member_id in member_id_list:
		return
		
	member_id_list.append(member_id)
	var users_row = USERS_ROW.instantiate()
	users_row.position.y = users_row_holder.get_child_count() * 50
	users_row.get_node("Label").text = member_id
	users_row_holder.add_child(users_row)
	chat_receive_message(member_id + " has joined the room.")

func chat_receive_message(message: String) -> void:
	var chat_host_row = CHAT_ROW.instantiate()
	chat_host_row.text = message + ""
	chat_row_holder.add_child(chat_host_row)
	
	if chat_tab_container.current_tab == 0:
		chat_unread_dot.show()

func chat_send_message() -> void:
	get_viewport().gui_release_focus()
	if chat_message_edit.text == "":
		return
		
	if is_live_editing:
		game_client._send_chat_message(chat_message_edit.text)
		chat_message_edit.text = ""
	
func chat_clear() -> void:
	for child in chat_row_holder.get_children():
		child.queue_free()
		
func users_clear() -> void:
	for child in users_row_holder.get_children():
		child.queue_free()
		
func _users_host_pressed():
	users_host_edit_panel.initialize()
	
func _users_join_quit_pressed():
	if is_live_editing:
		users_quit_edit_panel.initialize(users_room_edit.text)
	else:
		users_join_edit_panel.initialize()

func users_render(member_id_list: Array[String], host_id: String) -> void:
	users_clear()
	
	var users_host_row = USERS_ROW.instantiate()
	users_host_row.position.y = users_row_holder.get_child_count() * 50
	users_host_row.get_node("Label").text = host_id + "(HOST)"
	
	if host_id == Globals.Session.get_username():
		users_host_row.get_node("Label").text += "(ME)"
	
	var users_host_button = users_host_row.get_node("Button")
	users_host_button.button_pressed = true
	users_row_holder.add_child(users_host_row)
	
	for member_id in member_id_list:
		if member_id == host_id:
			continue
			
		var users_row = USERS_ROW.instantiate()
		users_row.position.y = users_row_holder.get_child_count() * 50
		
		if member_id == Globals.Session.get_username():
			users_row.get_node("Label").text = member_id + "(ME)"
		else:
			users_row.get_node("Label").text = member_id
		
		var users_button = users_host_row.get_node("Button")
		users_button.button_pressed = false
		users_row_holder.add_child(users_row)


func _on_message_edit_text_submitted(new_text: String) -> void:
	chat_send_message()

func _on_message_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		get_viewport().gui_release_focus()

func _on_tab_container_tab_changed(tab: int) -> void:
	if tab == 1:
		chat_unread_dot.hide()
