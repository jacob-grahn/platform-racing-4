extends Moon
class_name ClassicMoon


func init():
	display_color = Color("5488ff")
	light_atlas_coords = Vector2i(7, 3)
	lightbreak_type = LightTile.MOON
	super()
