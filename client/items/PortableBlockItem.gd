extends Node2D
class_name PortableBlockItem

@onready var character = get_node("../../..")
@onready var portableblock = load("res://item_effects/PortableBlock.tscn")
var using: bool = false
var remove: bool = false
var uses: int = 1


func _physics_process(delta):
	check_if_used()

func _ready():
	pass

func check_if_used():
	if uses < 1:
		remove = true

func activate_item():
	if !using:
		using = true
		uses -= 1

# unused at the moment, need to figure why the animation is not spawning at the player
# and why its not spawning a crumble block.
func use_block():
	var tile_map: TileMap = get_node("../../../../TileMap")
	var global_position = to_global(Vector2(0, 0))
	var tilemap_position = tile_map.to_local(global_position)
	var coords: Vector2i = Vector2i(tilemap_position.round()) / Settings.tile_size
	var tile_id = 18
	var atlas_coords: Vector2i = Helpers.to_atlas_coords(tile_id)
	var atlas_position: Vector2i = atlas_coords * Settings.tile_size
	var block = portableblock.instantiate()
	block.spawn_tile_id = tile_id
	block.spawn_tile_map = tile_map
	block.spawn_position = global_position
	block.spawn_tilemap_position = tilemap_position
	block.spawn_coords = coords
	block.spawn_atlas_coords = atlas_position
	block.spawn_atlas_position = atlas_position
	character.add_child.call_deferred(block)

func still_have_item():
	if !remove:
		return true
	else:
		return false
