extends Node2D

var target: Node2D
var rotation_velocity: float = 0
var tick_ms = 4000 # rotate 90 degrees every 4.5 seconds
var tock_ms = 500
var elapsed_ms = 0
var target_rotation = 0
var tick = 'tock'
var enabled = true
var enabled_temp = false # set to true to kick off only one rotation


func _ready():
	target = self


func _physics_process(delta):
	elapsed_ms += delta * 1000
	
	if (enabled || enabled_temp):
		if tick == 'tick' && elapsed_ms > tock_ms:
			elapsed_ms = 0
			target_rotation += (PI / 2) + (PI / 20)
			tick = 'tock'
		if tick == 'tock' && elapsed_ms > tick_ms:
			elapsed_ms = 0
			tick = 'tick'
			target_rotation -= PI / 20
	
	if enabled_temp && elapsed_ms >= tick_ms * 0.75:
		enabled_temp = false
		
	rotation_velocity += (target_rotation - target.rotation) / 5
	rotation_velocity = rotation_velocity * 0.93
	target.rotation += rotation_velocity * delta
