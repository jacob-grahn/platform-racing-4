extends Tile
class_name Bounce

const BOUNCINESS: float = 0.1


func init():
	matter_type = Tile.SOLID
	any_side.push_back(bounce)


func bounce(player: Node2D, tilemap: TileMapLayer, coords: Vector2i) -> void:
	var tile_position_local = (coords * Settings.tile_size) + Settings.tile_size_half
	var tile_position_global = tilemap.to_global(tile_position_local)
	
	if is_moving_towards(player.position, player.movement.previous_velocity, tile_position_global):
		# bounce, invert velocity
		player.velocity = player.movement.previous_velocity.bounce(player.tile_interaction.last_collision.get_normal())
		
		# add extra velocity
		player.velocity = player.velocity * (Vector2(1, 1) + (Vector2(BOUNCINESS, BOUNCINESS) * player.tile_interaction.last_collision.get_normal().abs()))
		
		# need a speed limit to keep bouncing back and forth from getting out of hand
		player.velocity = player.velocity.limit_length(3000)


# Function to determine if a body is moving towards a block
func is_moving_towards(body_pos: Vector2, body_velocity: Vector2, block_pos: Vector2) -> bool:
	# Calculate the vector from the body to the block
	var direction_to_block = block_pos - body_pos

	# Calculate the dot product of the body's velocity and the direction to the block
	var dot_product = body_velocity.dot(direction_to_block)

	# If the dot product is positive, the body is moving towards the block
	return dot_product > 0
