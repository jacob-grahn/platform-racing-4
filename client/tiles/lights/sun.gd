extends LightTile
class_name Sun


func init():
	display_color = Color("da1500")
	light_atlas_coords = Vector2i(6, 33)
	lightbreak_type = LightTile.SUN
	super()
	

func start_lightbreak(player: Node2D, coords: Vector2i) -> void:
	super(player, coords)
	player.lightbreak.fire_power += 1
