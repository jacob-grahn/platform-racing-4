class_name Tile

const STATIC = 'static'

const SOLID = 'solid'
const LIQUID = 'liquid'
const GAS = 'gas'

var top = []
var left = []
var right = []
var bottom = []
var any_side = [] # includes top, left, right, and bottom
var stand = [] # could be any side depending on player rotation
var bump = [] # could be any side depending on player rotation
var tick = [] # will run on some interval
var area = [] # used for tiles with no collision like water
var physics_type = STATIC
var matter_type = SOLID
var is_safe: bool = true


func init():
	pass


func clear():
	pass


func on(event: String, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	for behavior in self[event]:
		behavior.call(source, target, coords)


func activate_tilemap(tile_map: TileMap) -> void:
	pass


func get_center_position(tile_map: TileMap, coords: Vector2i) -> Vector2:
	return (Vector2(coords * Settings.tile_size) + Vector2(Settings.tile_size_half)).rotated(tile_map.rotation)
