extends LightTile
class_name Sun


func init():
	display_color = Color("da1500")
	atlas_coords = Vector2i(6, 3)
	lightbreak_type = LightTile.SUN
	super()
	

func start_lightbreak(player: Node2D, coords: Vector2i) -> void:
	super(player, coords)
	player.lightbreak_fire_power += 1

