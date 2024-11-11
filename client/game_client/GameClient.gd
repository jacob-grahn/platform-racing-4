extends Node2D
signal receive_level_event
signal request_editor_load

@export var SPLIT_SCREEN_STYLE := VERTICAL
@export var USE_RATIO := true

const OPEN = "open"
const CLOSED = "closed"

var websocket_url = Helpers.get_base_ws_url()
var is_live_editing = false
var current_module = "OnlineModule"
var is_host = false
var room = ""
var target_state = CLOSED
var socket: WebSocketPeer
var connect_attempt_count = 0
var send_queue = []
var edit_event_buffer = []
var isFirstOpenEditor = true

var cached_member_id_list: Array[String] = []
var cached_host_id = ""

@onready var connect_timer: Timer = $ConnectTimer
@onready var cursor_timer: Timer = $CursorTimer
var popup_panel: Control = null
var editor_events: Node2D = null
var now_editing_panel: Node2D = null
var layers: Node2D = null
var editor_cursors: Node2D = null
var is_scale_multiple_instances = false

func _ready() -> void:
	connect_timer.timeout.connect(_attempt_connect)
	cursor_timer.timeout.connect(_send_cursor_update)
	
	if is_scale_multiple_instances:
		scale_multiple_instances()
	
func _on_connect_editor() -> void:
	popup_panel = $"../EDITOR/UI/PopupPanel"
	editor_events = $"../EDITOR/EditorEvents"
	now_editing_panel = $"../EDITOR/UI/NowEditingPanel"
	layers = $"../EDITOR/Layers"
	editor_cursors = $"../EDITOR/EditorCursorLayer/EditorCursors"
	editor_events.connect("send_level_event", _on_send_level_event)
	
	if !isFirstOpenEditor:
		var data_room = {
			"module": "RequestRoomModule",
			"id": Session.get_username(),
			"ms": 5938,
			"room" : room,
			"ret": true,
		}
		send_queue.push_back(data_room)
	
	isFirstOpenEditor = false
	editor_cursors.add_new_cursor(Session.get_username())
	
func _on_send_level_event(event: Dictionary) -> void:
	if !is_live_editing:
		return
	
	event.user_id = Session.get_username()
	var data = {
		"module": "EditorModule",
		"id": Session.get_username(),
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
	connect_timer.stop()
	if socket && socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.close()
	socket = null

func _send_cursor_update() -> void:
	if is_live_editing && layers && is_instance_valid(layers):
		var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
		if !layer:
			return
			
		var tilemap: TileMap = layer.get_node("TileMap")
		var camera: Camera2D = get_viewport().get_camera_2d()
		var mouse_position = tilemap.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
		
		var data = {
			"module": "CursorEditorModule",
			"id": Session.get_username(),
			"ms": 5938,
			"room" : room,
			"ret": true,
			"cursor_update": {
				"coords": {
					"x": mouse_position.x,
					"y": mouse_position.y
				},
				"layer": layers.get_target_layer(),
				"block_id": Session.get_current_block_id()
			}
		}
		send_queue.push_back(data)

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
	
	connect_timer.stop()
	
	# Wait for the socket to connect.
	# await get_tree().create_timer(1).timeout
	
	# Send data.
	var data = {
		"module": current_module,
		"id": Session.get_username(),
		"ms": 5938,
		"room" : room,
		"ret": true
	}
	send_queue.push_back(data)


func _retry_connect() -> void:
	connect_timer.wait_time = connect_attempt_count + 1
	connect_timer.start()


func _process(delta: float) -> void:
	if layers && is_instance_valid(layers):
		var layer: ParallaxBackground = layers.get_node(layers.get_target_layer())
		if layer:
			var tilemap: TileMap = layer.get_node("TileMap")
			var camera: Camera2D = get_viewport().get_camera_2d()
			var mouse_position = tilemap.get_local_mouse_position() + camera.get_screen_center_position() - (camera.get_screen_center_position() * (1/layer.follow_viewport_scale))
			if editor_cursors && is_instance_valid(editor_cursors):
				editor_cursors.update_cursor_position_local(mouse_position, Session.get_current_block_id())
		
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
			#print("send ws (", Session.get_username(), ") :", JSON.stringify(update))
			send_queue.clear()
		while socket.get_available_packet_count():
			var packet = socket.get_packet().get_string_from_utf8()
			#print("receive ws (", Session.get_username(), ") :", packet)
			var parsed_packet = JSON.parse_string(packet)
			
			if parsed_packet.error_message == "RoomNotFoundErrorMessage":
				if is_live_editing:
					return
				
				if popup_panel && is_instance_valid(popup_panel) && parsed_packet.id == Session.get_username():
					popup_panel.initialize("Room not found", "Room: " + parsed_packet.room)
			elif parsed_packet.error_message == "RoomExistsErrorMessage":
				if is_live_editing:
					return
				
				if popup_panel && is_instance_valid(popup_panel) && parsed_packet.id == Session.get_username():
					popup_panel.initialize("Room already exists", "Room: " + parsed_packet.room)
			
			if parsed_packet.module == "ResponseEditorModule":
				is_live_editing = true
				cursor_timer.start()
				var request_editor = parsed_packet.request_editor
				Session.set_local_edit_id(request_editor.edit_id)
				
				var level_data = Marshalls.base64_to_utf8(request_editor.level_data)
				level_data = JSON.parse_string(level_data)
				
				Editor.current_level = level_data
				emit_signal("request_editor_load")
				
				if now_editing_panel && is_instance_valid(now_editing_panel):
					now_editing_panel.join_room(parsed_packet.room, cached_member_id_list, cached_host_id)
				
				if editor_cursors && is_instance_valid(editor_cursors):
					for member_id in cached_member_id_list:
						editor_cursors.add_new_cursor(member_id)
					cached_member_id_list.clear()
				
				if popup_panel && is_instance_valid(popup_panel):
					popup_panel.initialize("Join Success", "You have successfully joined the room: " + parsed_packet.room)
			elif parsed_packet.module == "RequestEditorModule":
				if !is_host:
					return
				
				var level_encoder: Node2D = $"../EDITOR/LevelEncoder"
				if !level_encoder:
					return
					
				var json_string = JSON.stringify(level_encoder.encode())
				var encoded_data = Marshalls.utf8_to_base64(json_string)
	
				var data = {
					"module": "ResponseEditorModule",
					"id": Session.get_username(),
					"target_user_id": parsed_packet.id,
					"ms": 5938,
					"room" : room,
					"ret": true,
					"request_editor": {
						"level_data": encoded_data,
						"edit_id": Session.get_local_edit_id()
					}
				}
				send_queue.push_back(data)
			elif parsed_packet.module == "JoinSuccessModule":
				if now_editing_panel && is_instance_valid(now_editing_panel):
					now_editing_panel.add_member(parsed_packet.id)
				if is_host or parsed_packet.id != Session.get_username():
					if !editor_cursors || !is_instance_valid(editor_cursors):
						return
						
					for member_id in parsed_packet.member_id_list:
						editor_cursors.add_new_cursor(member_id)
					return
					
				var data = {
					"module": "RequestEditorModule",
					"id": Session.get_username(),
					"ms": 5938,
					"room" : room,
					"ret": true,
				}
				
				for member_id in parsed_packet.member_id_list:
					cached_member_id_list.append(member_id)
				cached_host_id =  parsed_packet.host_id
				
				send_queue.push_back(data)
			elif parsed_packet.module == "HostSuccessModule":
				if parsed_packet.id != Session.get_username():
					return
					
				if is_host:
					return
					
				Session.set_local_edit_id(0)
				is_live_editing = true
				cursor_timer.start()
				is_host = true
				var member_id_list: Array[String] = [parsed_packet.id]
				
				if now_editing_panel && is_instance_valid(now_editing_panel):
					now_editing_panel.join_room(parsed_packet.room, member_id_list, parsed_packet.id)
					
				if popup_panel && is_instance_valid(popup_panel) && parsed_packet.id == Session.get_username():
					popup_panel.initialize("Host Success", "You have successfully hosted the room: " + parsed_packet.room)
			elif parsed_packet.module == "EditorModule":
				if Session.get_current_scene_name() != "EDITOR":
					edit_event_buffer.append(parsed_packet.editor)
				else:
					if parsed_packet.editor.user_id != Session.get_username():
						# Give the illusion that the remote cursor appears same time as the block
						await get_tree().create_timer(1).timeout
					emit_signal("receive_level_event", parsed_packet.editor)
			elif parsed_packet.module == "ResponseRoomModule":
				var member_id_list: Array[String] = []
				for member_id in parsed_packet.member_id_list:
					member_id_list.append(member_id)
					
					if editor_cursors && is_instance_valid(editor_cursors):
						editor_cursors.add_new_cursor(member_id)
				
				if now_editing_panel && is_instance_valid(now_editing_panel):
					now_editing_panel.join_room(parsed_packet.room, member_id_list, parsed_packet.host_id)
			elif parsed_packet.module == "CursorEditorModule":
				if editor_cursors && is_instance_valid(editor_cursors):
					var cursor_update = parsed_packet.cursor_update
					editor_cursors.update_cursor_position_remote(
						parsed_packet.id, 
						Vector2(cursor_update.coords.x, cursor_update.coords.y), 
						cursor_update.layer,
						cursor_update.block_id
					)

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
	
	if Session.get_current_scene_name() == "EDITOR":
		for packet in edit_event_buffer:
			emit_signal("receive_level_event", packet)

func scale_multiple_instances():
	var screen_count = 3
	
	for i in screen_count:
		var screen_rect = DisplayServer.screen_get_usable_rect(i)
		var screen_ratio = screen_rect.size.aspect()
		if SPLIT_SCREEN_STYLE == HORIZONTAL:
			get_window().size.x = screen_rect.size.x / 2
			get_window().size.y = get_window().size.x / screen_ratio if USE_RATIO else screen_rect.size.y
			get_window().position.y = screen_rect.position.y
		else:
			get_window().size.y = screen_rect.size.y / 2
			get_window().size.x = get_window().size.y * screen_ratio if USE_RATIO else screen_rect.size.x - 100
			get_window().position.x = screen_rect.position.x
			

		if OS.has_feature("server"):
			get_window().position.x = screen_rect.size.x / 2
			get_window().position.y = screen_rect.position.y
			get_window().size.y = screen_rect.size.y 
		# tl: top left, tr: top right, bl: bottom left, br: bottom right
		elif OS.has_feature("tl"):
			get_window().position = screen_rect.position
			get_window().position.y += 50
		elif OS.has_feature("bl"):
			get_window().position.y = screen_rect.size.y / 2
			get_window().position.y += 50
		elif OS.has_feature("tr"):
			get_window().position.x = screen_rect.size.x / 2
			get_window().position.y = screen_rect.position.y
		elif OS.has_feature("br"):
			get_window().position.x = screen_rect.size.x / 2 - 1000
			get_window().position.y =  screen_rect.size.y / 2

		#elif SPLIT_SCREEN_STYLE == HORIZONTAL:
			#get_window().position.x = screen_rect.size.x / 2
		#else:
			#get_window().position.y = screen_rect.size.y / 2
				
		#var args = OS.get_cmdline_user_args()
