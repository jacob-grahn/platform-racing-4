extends Node2D

const OPEN = "open"
const CLOSED = "closed"

var websocket_url = ""
var room = ""
var target_state = CLOSED
var socket: WebSocketPeer
var connect_attempt_count = 0
var send_queue = []
@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.timeout.connect(_attempt_connect)
	join("ws://localhost:8080/ws", "mars")
	
	
func join(url: String, room_name: String) -> void:
	_clear()
	connect_attempt_count = 0
	websocket_url = url
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
		"id": "1",
		"ms": 5938,
		"room" : room,
		"pos": {
			"x": 1,
			"y": 2,
			"vx": 3,
			"vy": 4
		},
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
			print("Got data from server: ", socket.get_packet().get_string_from_utf8())

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
