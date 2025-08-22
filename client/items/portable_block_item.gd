extends Node2D
class_name PortableBlockItem

@onready var VisualAid = $VisualAid
var character: Character
var using: bool = false
var remove: bool = false
var uses: int = 1
var tile_id = 0
var tile_map_layer: TileMapLayer
var spawn: Node2D
var spawn_position: Vector2
var tile_map_layer_position: Vector2
var coords: Vector2i
var atlas_coords: Vector2i
var below_zero: Vector2
var can_place: bool
var PortableBlock := load("res://item_effects/portable_block.tscn")


func _physics_process(delta):
	set_block_position()
	check_if_used()


func _ready():
	tile_id = 44
	set_block_position()


func set_block_position():
	can_place = false
	var layer = Game.get_target_layer_node()
	tile_map_layer = layer.tile_map_layer
	spawn = layer.get_node("Projectiles")
	spawn_position = to_local(Vector2(0, 0))
	tile_map_layer_position = tile_map_layer.to_local(character.global_position)
	coords = Vector2i(tile_map_layer_position.floor()) / Settings.tile_size
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
	var tile_data = tile_map_layer.get_cell_source_id(coords)
	if tile_data == -1:
		can_place = true
	if !using:
		VisualAid.global_position = Vector2i((coords.x * Settings.tile_size.x) + ((Settings.tile_size.x / 2) * below_zero.x), (coords.y * Settings.tile_size.y) + ((Settings.tile_size.y / 2) * below_zero.y))
		VisualAid.global_rotation = 0
		VisualAid.scale.x = 1
		VisualAid.scale.y = 1
		if can_place:
			VisualAid.self_modulate = Color(0.625, 1, 0.625, 0.5)
		else:
			VisualAid.self_modulate = Color(1, 0.625, 0.625, 0.5)


func check_if_used():
	if uses < 1:
		remove = true


func activate_item():
	if !using and can_place:
		using = true
		use_block()
		uses -= 1


func use_block():
	set_block_position()
	var block = PortableBlock.instantiate()
	block.global_position = Vector2i((coords.x * Settings.tile_size.x) + ((Settings.tile_size.x / 2) * below_zero.x), (coords.y * Settings.tile_size.y) + ((Settings.tile_size.y / 2) * below_zero.y))
	block.tile_map_layer = tile_map_layer
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
