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


func init():
	pass


func clear():
	pass


func on(event: String, source: Node2D, target: Node2D, coords: Vector2i) -> void:
	for behavior in self[event]:
		behavior.call(source, target, coords)


func activate_tilemap(tilemap: TileMap) -> void:
	pass
