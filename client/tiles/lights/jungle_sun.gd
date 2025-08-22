extends Sun
class_name JungleSun


func init():
	display_color = Color("da1500")
	light_atlas_coords = Vector2i(6, 18)
	lightbreak_type = LightTile.SUN
	super()
