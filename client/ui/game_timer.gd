extends Control
class_name GameTimer

signal increase_time(new_timer: float)

@onready var timer_text = $TimeText
@onready var timer = $FrameTimer

var physics_timer: float = 0
var game
var player


func _ready() -> void:
	timer.process_callback = 1
	timer.one_shot = true
	timer.wait_time = 120

func init(game_scene):
	game = game_scene
	player = game_scene.get_node("PlayerManager").get_character()
	player.connect("increase_time", _inc_timer)
	timer.connect("timeout", _finish_player)

func _physics_process(delta: float) -> void:
	if !timer.is_stopped():
		physics_timer += delta
		update_display()

func update_display():
	var counter = 0
	var hours = 0
	var minutes = 0
	var seconds = 0
	var milliseconds = 0
	var time_string = ""
	while 3600 * (counter + 1) < timer.time_left:
		counter += 1
		hours += 1
	counter = 0
	while 60 * (counter + 1) < (timer.time_left - (3600 * hours)):
		counter += 1
		minutes += 1
	counter = 0
	while 1 * (counter + 1) < (timer.time_left - ((3600 * hours) + (60 * minutes))):
		counter += 1
		seconds += 1
	counter = 0
	while 0.001 * (counter + 1) < (timer.time_left - ((3600 * hours) + (60 * minutes) + (1 * seconds))):
		counter += 1
		milliseconds += 1
	var minutestext = ""
	var secondstext = ""
	var millisecondstext = ""
	if len(str(minutes)) > 1:
		minutestext = str(minutes)
	else:
		minutestext = "0" + str(minutes)
	if len(str(seconds)) > 1:
		secondstext = str(seconds)
	else:
		secondstext = "0" + str(seconds)
	if len(str(milliseconds)) > 2:
		millisecondstext = str(milliseconds)
	elif len(str(milliseconds)) > 1:
		millisecondstext = "0" + str(milliseconds)
	else:
		millisecondstext = "00" + str(milliseconds)
	if hours > 0:
		time_string = str(hours) + ":" + minutestext + ":" + secondstext + "." + millisecondstext
	else:
		time_string = minutestext + ":" + secondstext + "." + millisecondstext
	timer_text.text = time_string

func set_timer(new_timer: float):
	timer.wait_time = new_timer

func _inc_timer(increment: float):
	timer.start(timer.time_left + increment)

func start_timer():
	timer.start()

func pause_timer(switch: bool):
	timer.set_paused(switch)

func stop_timer():
	timer.stop()

func _finish_player():
	if !player.movement.finished:
		player.movement.finished = true
	update_display()
