extends Firefly
class_name DesertFirefly


func init():
	display_color = Color("00d163")
	light_atlas_coords = Vector2i(8, 8)
	lightbreak_type = LightTile.FIREFLY
	super()
