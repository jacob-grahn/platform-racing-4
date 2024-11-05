extends Node2D

signal explore_load

const EXPLORE_ROW = preload("res://pages/editor/explore_panel/ExploreRow.tscn")
var room_id = ""
var is_live_editing = false
var is_host = false

@onready var row_holder = $ScrollContainer/RowHolder
@onready var host_button = $HostButton
@onready var join_button = $JoinButton
@onready var RoomEdit = $RoomEdit
@onready var http_request = $HTTPRequest
@onready var host_edit_panel = $"../HostEditPanel"
@onready var join_edit_panel = $"../JoinEditPanel"

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
	
func join_room(room: String):
	RoomEdit.text = room
	host_button.disabled = true
	join_button.disabled = true
