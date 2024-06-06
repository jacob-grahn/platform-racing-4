extends Node2D


func get_base_url() -> String:
	if '--local' in OS.get_cmdline_args() || OS.is_debug_build() || OS.get_environment('PR_ENV') == 'local':
		# return 'http://localhost'
		return 'https://dev.platformracing.com'
	elif '--dev' in OS.get_cmdline_args() || OS.get_environment('PR_ENV') == 'dev':
		return 'https://dev.platformracing.com'
	else:
		return 'https://platformracing.com'


func set_scene(scene: PackedScene):
	get_node("/root/Main").set_scene(scene)


func to_atlas_coords(block_id: int) -> Vector2i:
	var id = block_id - 1
	var x = id % 10
	var y = id / 10
	return Vector2i(x, y)


func to_block_id(atlas_coords: Vector2i) -> int:
	return (atlas_coords.y * 10) + atlas_coords.x + 1
