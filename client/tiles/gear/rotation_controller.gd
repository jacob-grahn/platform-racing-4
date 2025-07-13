extends Node2D
class_name RotationController

var rotation_velocity: float = 0
var tick_ms = 4000 # rotate 90 degrees every 4.5 seconds
var tock_ms = 500
var elapsed_ms = 0
var target_rotation = 0
var tick = 'tock'
var enabled = true
var enabled_temp = false # set to true to kick off only one rotation
var init_timer = 0.2


func _ready():
	pass


func _physics_process(delta):
	
	# workaround for a bug when setting tile_map_layer.collision_animatable = true
	if init_timer > 0:
		init_timer -= delta
		for child in get_children():
			child.position = Settings.tile_size_half * -1
		return
	
	# rotate!
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
		
	rotation_velocity += (target_rotation - rotation) / 5
	rotation_velocity = rotation_velocity * 0.93
	rotation += rotation_velocity * delta
	
	# this is needed to let the tile_map_layer know something has changed and it needs to update
	for child in get_children():
		child.rotation = 0
