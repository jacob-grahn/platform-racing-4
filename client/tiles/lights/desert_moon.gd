extends Moon
class_name DesertMoon


func init():
	display_color = Color("5488ff")
	light_atlas_coords = Vector2i(7, 8)
	lightbreak_type = LightTile.MOON
	super()
