extends LightTile
class_name Moon


func init():
	display_color = Color("5488ff")
	atlas_coords = Vector2i(7, 3)
	lightbreak_type = LightTile.MOON
	super()
	

func start_lightbreak(player: Node2D, coords: Vector2i) -> void:
	super(player, coords)
	player.lightbreak.moon_timer = 0.05
