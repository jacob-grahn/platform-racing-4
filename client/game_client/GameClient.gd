extends Node2D
signal receive_level_event
signal request_editor_load

const OPEN = "open"
const CLOSED = "closed"

var websocket_url = Helpers.get_base_ws_url()
var is_live_editing = false
var current_module = "OnlineModule"
var is_host = false
var is_requesting_editor_update = false
var username = generate_username()
var room = ""
var target_state = CLOSED
var socket: WebSocketPeer
var connect_attempt_count = 0
var send_queue = []

var cached_member_id_list: Array[String] = []
var cached_host_id = ""

@onready var timer: Timer = $Timer
@onready var editor_events: Node2D = get_node("../EditorEvents")
@onready var popup_panel: Control = $"../UI/PopupPanel"
@onready var now_editing_panel: Node2D = $"../UI/NowEditingPanel"
@onready var level_encoder: Node2D = $"../LevelEncoder"

func _ready() -> void:
	timer.timeout.connect(_attempt_connect)
	
	editor_events.connect("send_level_event", _on_send_level_event)
	
func _on_send_level_event(event: Dictionary) -> void:
	if !is_live_editing:
		return
		
	var data = {
		"module": "EditorModule",
		"id": username,
		"ms": 5938,
		"room" : room,
		"ret": true,
		"editor": event
	}
	send_queue.push_back(data)

func join(room_name: String, is_host_requested: bool) -> void:
	if is_host_requested:
		current_module = "HostEditorModule"
	else:
		current_module = "JoinEditorModule"
		
	_clear()
	connect_attempt_count = 0
	room = room_name
	target_state = OPEN
	_attempt_connect()


func close() -> void:
	_clear()
	target_state = CLOSED


func _clear() -> void:
	timer.stop()
	if socket && socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.close()
	socket = null


# Initiate connection to the given URL.
func _attempt_connect() -> void:
	print("_attempt_connect: ", websocket_url, ", ", room)
	connect_attempt_count += 1
	socket = WebSocketPeer.new()
	var err = socket.connect_to_url(websocket_url)
	if err != OK:
		print("Unable to connect")
		if target_state == OPEN:
			_retry_connect()
		return
	
	timer.stop()
	
	# Wait for the socket to connect.
	# await get_tree().create_timer(1).timeout
	
	# Send data.
	var data = {
		"module": current_module,
		"id": username,
		"ms": 5938,
		"room" : room,
		"ret": true
	}
	send_queue.push_back(data)


func _retry_connect() -> void:
	timer.wait_time = connect_attempt_count + 1
	timer.start()


func _process(delta: float) -> void:
	
	# only proceed if socket exists
	if !socket:
		return
		
	# Call this in _process or _physics_process. Data transfer and state updates
	# will only happen when calling this function.
	socket.poll()

	# get_ready_state() tells you what state the socket is in.
	var state = socket.get_ready_state()

	# WebSocketPeer.STATE_OPEN means the socket is connected and ready to send and receive data.
	if state == WebSocketPeer.STATE_OPEN:
		for update in send_queue:
			socket.send_text(JSON.stringify(update))
			send_queue = []
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			
			var parsed_packet = JSON.parse_string(packet)
			
			if parsed_packet.error_message == "RoomNotFoundErrorMessage":
				if is_live_editing:
					return
					
				popup_panel.initialize("Room not found", "Room: " + parsed_packet.room)
			elif parsed_packet.error_message == "RoomExistsErrorMessage":
				if is_live_editing:
					return
					
				popup_panel.initialize("Room already exists", "Room: " + parsed_packet.room)
			
			if parsed_packet.module == "ResponseEditorModule":
				if !is_requesting_editor_update:
					return
				
				is_requesting_editor_update = false
				is_live_editing = true
				var request_editor = parsed_packet.request_editor
				Session.set_local_edit_id(request_editor.edit_id)
				
				var level_data = Marshalls.base64_to_utf8(request_editor.level_data)
				level_data = JSON.parse_string(level_data)
				
				Editor.current_level = level_data
				emit_signal("request_editor_load")
				
				now_editing_panel.join_room(parsed_packet.room, cached_member_id_list, cached_host_id)
				popup_panel.initialize("Join Success", "You have successfully joined the room: " + parsed_packet.room)
			elif parsed_packet.module == "RequestEditorModule":
				if !is_host:
					return
				
				var json_string = JSON.stringify(level_encoder.encode())
				var encoded_data = Marshalls.utf8_to_base64(json_string)
	
				var data = {
					"module": "ResponseEditorModule",
					"id": username,
					"ms": 5938,
					"room" : room,
					"ret": false,
					"request_editor": {
						"level_data": encoded_data,
						"edit_id": Session.get_local_edit_id()
					}
				}
				send_queue.push_back(data)
			elif parsed_packet.module == "JoinSuccessModule":
				now_editing_panel.add_member(parsed_packet.id)
				if is_host:
					return
					
				is_requesting_editor_update = true
				var data = {
					"module": "RequestEditorModule",
					"id": username,
					"ms": 5938,
					"room" : room,
					"ret": false,
				}
				
				for member_id in parsed_packet.member_id_list:
					cached_member_id_list.append(member_id)
				cached_host_id =  parsed_packet.host_id
				
				send_queue.push_back(data)
			elif parsed_packet.module == "HostSuccessModule":
				if is_host:
					return
					
				Session.set_local_edit_id(0)
				is_live_editing = true
				is_host = true
				var member_id_list: Array[String] = [parsed_packet.id]
				now_editing_panel.join_room(parsed_packet.room, member_id_list, parsed_packet.id)
				popup_panel.initialize("Host Success", "You have successfully hosted the room: " + parsed_packet.room)
			elif parsed_packet.module == "EditorModule":
				emit_signal("receive_level_event", parsed_packet.editor)

	# WebSocketPeer.STATE_CLOSING means the socket is closing.
	# It is important to keep polling for a clean close.
	elif state == WebSocketPeer.STATE_CLOSING:
		pass

	# WebSocketPeer.STATE_CLOSED means the connection has fully closed.
	# It is now safe to stop polling.
	elif state == WebSocketPeer.STATE_CLOSED:
		# The code will be -1 if the disconnection was not properly notified by the remote peer.
		var code = socket.get_close_code()
		print("WebSocket closed with code: %d. Clean: %s" % [code, code != -1])
		_clear()
		if target_state == OPEN:
			_retry_connect()

func generate_username() -> String:
	var adjectives = ["Brave", "Clever", "Eager", "Mighty", "Swift", "Wise"]
	var nouns = ["Tiger", "Falcon", "Wizard", "Knight", "Phoenix", "Ranger"]
	var adjective = adjectives[randi() % adjectives.size()]
	var noun = nouns[randi() % nouns.size()]
	var number = str(randi() % 1000) 
	return adjective + noun + number
