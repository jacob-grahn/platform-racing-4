extends ParallaxBackground
class_name ArtLayer

@onready var stamps = $Stamps
@onready var lines = $Lines
@onready var texts = $Texts

var z_axis = 10
var depth = 10
var art_scale = 1.0
var art_rotation = 0
var alpha = 100


func init(tiles: Tiles) -> void:
	set_z_axis(z_axis)
	set_depth(depth)
	set_art_rotation(art_rotation)
	set_art_alpha(alpha)


func set_z_axis(p_z_axis: int) -> void:
	z_axis = p_z_axis
	set_viewport_scale()


func set_depth(p_depth: int) -> void:
	depth = p_depth
	layer = depth
	set_viewport_scale()


func set_viewport_scale():
	var z_axis_compat = float(z_axis)
	var depth_compat = float(depth)
	var base_scale = depth_compat / z_axis_compat
	follow_viewport_scale = base_scale


func set_art_rotation(new_rotation: float) -> void:
	art_rotation = new_rotation
	stamps.rotation_degrees = art_rotation
	lines.rotation_degrees = art_rotation
	texts.rotation_degrees = art_rotation

func set_art_alpha(new_alpha: float) -> void:
	alpha = new_alpha
	stamps.modulate = Color(1, 1, 1, (alpha / 100))
	lines.modulate = Color(1, 1, 1, (alpha / 100))
	texts.modulate = Color(1, 1, 1, (alpha / 100))
