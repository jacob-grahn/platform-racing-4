extends Node2D

@onready var animtimer = $AnimationTimer
@onready var animations: AnimationPlayer = $Animations

var coords: Vector2i
var atlas_coords: Vector2i
var tile_map_layer: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	animtimer.connect("timeout", _place_block)
	animtimer.start()
	animations.play("spawn")
	Jukebox.play_sound("mineappear")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass
	
func _place_block():
	tile_map_layer.set_cell(coords, 0, atlas_coords)
	queue_free()
