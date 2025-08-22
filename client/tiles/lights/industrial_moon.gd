extends Moon
class_name IndustrialMoon


func init():
	display_color = Color("5488ff")
	light_atlas_coords = Vector2i(7, 13)
	lightbreak_type = LightTile.MOON
	super()
