extends Node
class_name TestRunner

static func run_tests(main_instance: Main):
	var args = OS.get_cmdline_args()
	var test_arg_index = args.find("--run-tests")

	if test_arg_index == -1:
		return false

	var tests_to_run: Array
	if test_arg_index + 1 < args.size() and not args[test_arg_index + 1].begins_with("--"):
		tests_to_run = args[test_arg_index + 1].split(",")
	else:
		tests_to_run = ["game"]

	if "all" in tests_to_run:
		tests_to_run = ["game", "editor", "tester"]

	for test in tests_to_run:
		match test:
			"game":
				await _run_game_test(main_instance)
			"editor":
				await _run_editor_test(main_instance)
			"tester":
				await _run_tester_test(main_instance)

	main_instance.get_tree().quit()
	return true


static func _run_game_test(main_instance: Main):
	Game.pr2_level_id = "50815"
	await main_instance._set_scene(Main.GAME)
	await main_instance.get_tree().create_timer(2.0).timeout

	var character = Global.character
	if character:
		if not character.is_on_floor():
			print("Character is not on the floor at the end of the game test.")
			main_instance.get_tree().quit(1)
	else:
		print("Failed to get character instance.")
		main_instance.get_tree().quit(1)


static func _run_editor_test(main_instance: Main):
	var level_editor = await main_instance._set_scene(Main.LEVEL_EDITOR)
	await main_instance.get_tree().process_frame
	await main_instance.get_tree().create_timer(3.0).timeout


static func _run_tester_test(main_instance: Main):
	await main_instance._set_scene(Main.TESTER)
	await main_instance.get_tree().create_timer(3.0).timeout
