extends Node2D

@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations

var tile_id: int
var tile_map: TileMap
var spawn_position: Vector2i
var tilemap_spawn_position: Vector2i
var coords: Vector2i
var atlas_coords: Vector2i
var atlas_position: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = spawn_position
	var tilemap_position = tilemap_spawn_position
	animtimer.connect("timeout", _place_block)
	animtimer.start()
	animations.play("spawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func _place_block():
	tile_map.set_cell(0, coords, 0, atlas_coords)
	queue_free()
