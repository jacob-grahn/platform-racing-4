extends Node2D
signal receive_level_event

const OPEN = "open"
const CLOSED = "closed"

var websocket_url = "ws://localhost:8081/ws"
var is_live_editing = false
var current_module = "OnlineModule"
var is_host = false
var username = "xue"
var room = ""
var target_state = CLOSED
var socket: WebSocketPeer
var connect_attempt_count = 0
var send_queue = []
@onready var timer: Timer = $Timer
@onready var editor_events: Node2D = get_node("../EditorEvents")
@onready var popup_panel: Control = $"../UI/PopupPanel"
@onready var now_editing_panel: Node2D = $"../UI/NowEditingPanel"

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
			print("Sending: ", update)
			socket.send_text(JSON.stringify(update))
			send_queue = []
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			print("Got data from server: ", packet)
			
			var parsed_packet = JSON.parse_string(packet)
			
			if parsed_packet.error_message == "RoomNotFoundErrorMessage":
				popup_panel.initialize("Room not found", "Room: " + parsed_packet.room)
			elif parsed_packet.error_message == "RoomExistsErrorMessage":
				popup_panel.initialize("Room already exists", "Room: " + parsed_packet.room)
			
			if parsed_packet.module == "JoinSuccessModule":
				is_live_editing = true
				now_editing_panel.join_room(parsed_packet.room)
				popup_panel.initialize("Join Success", "You have successfully joined the room: " + parsed_packet.room)
			elif parsed_packet.module == "HostSuccessModule":
				is_live_editing = true
				now_editing_panel.join_room(parsed_packet.room)
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
