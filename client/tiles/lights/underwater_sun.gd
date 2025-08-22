extends Sun
class_name UnderwaterSun


func init():
	display_color = Color("da1500")
	light_atlas_coords = Vector2i(6, 28)
	lightbreak_type = LightTile.SUN
	super()
