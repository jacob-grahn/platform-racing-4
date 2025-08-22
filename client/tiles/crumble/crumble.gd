extends Tile
class_name Crumble

const START_HEALTH = 100
const ARMOR = 10
const DAMAGE_RATIO = 0.03

var health_dict = {}


func init():
	matter_type = Tile.ACTIVE
	is_safe = false
	any_side.push_back(crumble)


func crumble(player: Node2D, tile_map_layer: TileMapLayer, coords: Vector2i):
	var key = get_slug(tile_map_layer, coords)
	
	# oh shit, math
	# we want the velocity of the player, but only the % of the velocity that is moving towards the block
	# this is vector projection
	var magnitude = player.movement.last_velocity.length()
	var direction = player.movement.last_collision_normal
	var dot = player.movement.last_velocity.dot(direction)
	var projection = (dot / direction.length_squared()) * direction
	var magnitude_towards = projection.length()
	var damage = (magnitude_towards * DAMAGE_RATIO) - ARMOR
	var pieces = 1
	if damage > 0:
		var tile_health = health_dict.get(key, START_HEALTH)
		tile_health -= damage
		health_dict[key] = tile_health
		print(damage)
		if tile_health <= 0:
			TileEffects.shatter(tile_map_layer, coords, 10)
		else:
			while damage > 0:
				damage -= 9
				pieces += 1
			TileEffects.crumble(tile_map_layer, coords, pieces)
	# print({
	#	"key": key,
	#	"player_velocity" :player.last_velocity,
	#	"magnitude": magnitude,
	#	"direction": direction,
	#	"dot": dot,
	#	"projection": projection,
	#	"magnitude_towards": magnitude_towards
	#})


func clear():
	health_dict = {}
