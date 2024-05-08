extends Node2D


func get_base_url() -> String:
	if '--local' in OS.get_cmdline_args() || OS.is_debug_build() || OS.get_environment('PR_ENV') == 'local':
		# return 'http://localhost'
		return 'https://dev.platformracing.com'
	elif '--dev' in OS.get_cmdline_args() || OS.get_environment('PR_ENV') == 'dev':
		return 'https://dev.platformracing.com'
	else:
		return 'https://platformracing.com'


func set_scene(scene_name: String):
	get_node("/root/Main").set_scene(scene_name)
