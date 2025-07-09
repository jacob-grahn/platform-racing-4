extends Node2D
class_name PortableBlockItem

@onready var spawn = get_node("../../../../../Projectiles")
@onready var VisualAid = $VisualAid
var character: Character
var using: bool = false
var remove: bool = false
var uses: int = 1
var tile_id = 0
var tile_map: TileMapLayer
var spawn_position: Vector2
var tilemap_position: Vector2
var coords: Vector2i
var atlas_coords: Vector2i
var below_zero: Vector2
var PortableBlock := load("res://item_effects/portable_block.tscn")


func _physics_process(delta):
	set_block_position()
	check_if_used()


func _ready():
	tile_id = 18
	set_block_position()


func set_block_position():
	tile_map = get_node("../../../../../TileMap")
	if not tile_map or not character:
		return
	spawn_position = to_local(Vector2(0, 0))
	tilemap_position = tile_map.to_local(character.global_position)
	coords = Vector2i(tilemap_position.floor()) / Settings.tile_size
	if character.movement.facing > 0 and floor(character.global_position.x / Settings.tile_size.x) != round(character.global_position.x / Settings.tile_size.x):
		coords.x = coords.x + 1
	elif character.movement.facing < 0 and ceil(character.global_position.x / Settings.tile_size.x) != round(character.global_position.x / Settings.tile_size.x):
		coords.x = coords.x - 1
	if round((character.global_position.y + (Settings.tile_size.y / 2)) / Settings.tile_size.y) != round(character.global_position.y / Settings.tile_size.y):
		coords.y = coords.y - 1
	atlas_coords = CoordinateUtils.to_atlas_coords(tile_id)
	below_zero = Vector2(1, 1)
	if character.global_position.x < 0:
		below_zero.x = -1
	if character.global_position.y < 0:
		below_zero.y = -1
	if !using:
		VisualAid.global_position = Vector2i((coords.x * Settings.tile_size.x) + ((Settings.tile_size.x / 2) * below_zero.x), (coords.y * Settings.tile_size.y) + ((Settings.tile_size.y / 2) * below_zero.y))
		VisualAid.global_rotation = 0
		VisualAid.scale.x = 1
		VisualAid.scale.y = 1


func check_if_used():
	if uses < 1:
		remove = true


func activate_item():
	if !using:
		using = true
		use_block()
		uses -= 1


func use_block():
	set_block_position()
	var block = PortableBlock.instantiate()
	block.global_position = VisualAid.global_position
	block.tile_map = tile_map
	below_zero = Vector2(0, 0)
	if character.global_position.x < 0:
		below_zero.x = -1
	if character.global_position.y < 0:
		below_zero.y = -1
	block.coords = Vector2i(coords.x + below_zero.x, coords.y + below_zero.y)
	block.atlas_coords = atlas_coords
	spawn.add_child.call_deferred(block)


func still_have_item():
	if !remove:
		return true
	else:
		return false
