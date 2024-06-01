extends Node2D
class_name SliderItem

@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer

var next_animation: String


func _ready():
	timer.connect("timeout", _on_timeout)


func appear(delay: float) -> void:
	next_animation = "appear"
	if delay == 0:
		_on_timeout()
	else:
		timer.wait_time = delay
		timer.start()


func disappear(delay: float) -> void:
	next_animation = "disappear"
	if delay == 0:
		_on_timeout()
	else:
		timer.wait_time = delay
		timer.start()


func get_dimensions() -> Vector2:
	return Settings.tile_size


func _on_timeout() -> void:
	animation_player.play(next_animation)
