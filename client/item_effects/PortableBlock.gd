extends Node2D

@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations

var spawn_tile_id: int
var spawn_atlas_coords: Vector2i
var spawn_atlas_position: Vector2i
var spawn_tile_map: TileMap
var spawn_position: Vector2i
var tilemap_spawn_position: Vector2i
var spawn_coords: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	animtimer.connect("timeout", _place_block)
	animtimer.start()
	animations.play("spawn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func _place_block():
	var tile_id: int = spawn_tile_id
	var atlas_coords: Vector2i = spawn_atlas_coords
	var atlas_position: Vector2i = spawn_atlas_position
	var tile_map:TileMap = spawn_tile_map
	var global_position: Vector2i = spawn_position
	var tilemap_position: Vector2i = tilemap_spawn_position
	var coords: Vector2i = spawn_coords
	tile_map.set_cell(0, coords, 0, atlas_coords)
	queue_free()
