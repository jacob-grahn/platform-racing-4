extends Camera2D

var velocity = 1000


func _ready():
	pass # Replace with function body.


func _process(delta):
	var control_vector = Input.get_vector("left", "right", "up", "down")
	position += control_vector * delta * velocity
