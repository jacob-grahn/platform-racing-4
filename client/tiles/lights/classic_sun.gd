extends Sun
class_name ClassicSun


func init():
	display_color = Color("da1500")
	light_atlas_coords = Vector2i(6, 3)
	lightbreak_type = LightTile.SUN
	super()
