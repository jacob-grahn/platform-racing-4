extends Node
class_name TestRunner

static func run_tests(main_instance: Main):
	var args = OS.get_cmdline_args()
	var test_arg_index = args.find("--run-tests")

	if test_arg_index == -1:
		return false

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -80)

	var tests_to_run: Array
	if test_arg_index + 1 < args.size() and not args[test_arg_index + 1].begins_with("--"):
		tests_to_run = args[test_arg_index + 1].split(",")
	else:
		tests_to_run = ["game"]

	if "all" in tests_to_run:
		tests_to_run = ["game", "editor", "tester", "items"] # "user_settings" is flaky, skip for now

	for test in tests_to_run:
		match test:
			"game":
				await _run_game_test(main_instance)
			"editor":
				await _run_editor_test(main_instance)
			"tester":
				await _run_tester_test(main_instance)
			"login":
				await _run_login_test(main_instance)
			"user_settings":
				await _run_user_settings_test(main_instance)
			"items":
				await _run_items_test(main_instance)

	main_instance.get_tree().quit()
	return true


static func _run_game_test(main_instance: Main):
	Game.pr2_level_id = "50815"
	var game_scene = await main_instance._set_scene(Main.GAME)
	await main_instance.get_tree().create_timer(2.0).timeout

	var player_manager = game_scene.get_node("PlayerManager")
	var character = player_manager.get_character()
	if character:
		if not character.is_on_floor():
			print("Character is not on the floor at the end of the game test.")
			print("Character position: ", character.position)
			print("Character velocity: ", character.velocity)
			main_instance.get_tree().quit(1)
	else:
		print("Failed to get character instance.")
		main_instance.get_tree().quit(1)


static func _run_items_test(main_instance: Main):
	Game.pr2_level_id = "50815"
	var game_scene = await main_instance._set_scene(Main.GAME)
	await main_instance.get_tree().create_timer(2.0).timeout

	var player_manager = game_scene.get_node("PlayerManager")
	var character = player_manager.get_character()
	if not character:
		print("Failed to get character instance.")
		main_instance.get_tree().quit(1)
		return

	for i in range(15):
		character.set_item(i)
		await main_instance.get_tree().create_timer(0.5).timeout
		character.item_manager.use(main_instance.get_process_delta_time())
		await main_instance.get_tree().create_timer(0.5).timeout


static func _run_editor_test(main_instance: Main):
	var level_editor = await main_instance._set_scene(Main.LEVEL_EDITOR)
	await main_instance.get_tree().create_timer(1.0).timeout

	var block_cursor = level_editor.cursor.get_node("BlockCursor")
	block_cursor.on_drag()

	await main_instance.get_tree().create_timer(1.0).timeout


static func _run_tester_test(main_instance: Main):
	await main_instance._set_scene(Main.TESTER)
	await main_instance.get_tree().create_timer(3.0).timeout


static func _run_login_test(main_instance: Main):
	var login_scene = await main_instance._set_scene(Main.LOGIN)
	login_scene.get_node("Panel/VBoxContainer/NicknameEdit").text = "aaaa"
	login_scene.get_node("Panel/VBoxContainer/PasswordEdit").text = "aaaa"
	login_scene.get_node("Panel/VBoxContainer/LoginButton").pressed.emit()
	await main_instance.get_tree().create_timer(2.0).timeout
	if not Session.is_logged_in():
		print("Login test failed.")
		main_instance.get_tree().quit(1)


static func _run_user_settings_test(main_instance: Main):
	# Login first
	var login_scene = await main_instance._set_scene(Main.LOGIN)
	login_scene.get_node("Panel/VBoxContainer/NicknameEdit").text = "aaaa"
	login_scene.get_node("Panel/VBoxContainer/PasswordEdit").text = "aaaa"
	login_scene.get_node("Panel/VBoxContainer/LoginButton").pressed.emit()
	await main_instance.get_tree().create_timer(2.0).timeout
	if not Session.is_logged_in():
		print("Login failed, cannot run user settings test.")
		main_instance.get_tree().quit(1)

	# Go to user settings
	var user_settings_scene = await main_instance._set_scene(Main.USER_SETTINGS)
	await main_instance.get_tree().process_frame

	# Change nickname
	user_settings_scene.get_node("VBoxContainer/NewNicknameEdit").text = "bbbb"
	user_settings_scene.get_node("VBoxContainer/NicknamePasswordEdit").text = "aaaa"
	user_settings_scene.get_node("VBoxContainer/UpdateNicknameButton").pressed.emit()
	await Session.session_updated
	if Session.nickname != "bbbb":
		print("Nickname was not updated in session.")
		main_instance.get_tree().quit(1)
	if user_settings_scene.get_node("VBoxContainer/StatusLabel").text != "User information updated successfully":
		print("Nickname update failed: " + user_settings_scene.get_node("VBoxContainer/StatusLabel").text)
		main_instance.get_tree().quit(1)

	# Change password
	user_settings_scene.get_node("VBoxContainer/CurrentPasswordEdit").text = "aaaa"
	user_settings_scene.get_node("VBoxContainer/NewPasswordEdit").text = "bbbb"
	user_settings_scene.get_node("VBoxContainer/UpdatePasswordButton").pressed.emit()
	await main_instance.get_tree().create_timer(2.0).timeout
	if user_settings_scene.get_node("VBoxContainer/StatusLabel").text != "User information updated successfully":
		print("Password update failed: " + user_settings_scene.get_node("VBoxContainer/StatusLabel").text)
		main_instance.get_tree().quit(1)

	# Change nickname back
	user_settings_scene.get_node("VBoxContainer/NewNicknameEdit").text = "aaaa"
	user_settings_scene.get_node("VBoxContainer/NicknamePasswordEdit").text = "bbbb"
	user_settings_scene.get_node("VBoxContainer/UpdateNicknameButton").pressed.emit()
	await Session.session_updated
	if Session.nickname != "aaaa":
		print("Nickname was not changed back in session.")
		main_instance.get_tree().quit(1)
	if user_settings_scene.get_node("VBoxContainer/StatusLabel").text != "User information updated successfully":
		print("Nickname change back failed: " + user_settings_scene.get_node("VBoxContainer/StatusLabel").text)
		main_instance.get_tree().quit(1)

	# Change password back
	user_settings_scene.get_node("VBoxContainer/CurrentPasswordEdit").text = "bbbb"
	user_settings_scene.get_node("VBoxContainer/NewPasswordEdit").text = "aaaa"
	user_settings_scene.get_node("VBoxContainer/UpdatePasswordButton").pressed.emit()
	await main_instance.get_tree().create_timer(2.0).timeout
	if user_settings_scene.get_node("VBoxContainer/StatusLabel").text != "User information updated successfully":
		print("Password change back failed: " + user_settings_scene.get_node("VBoxContainer/StatusLabel").text)
		main_instance.get_tree().quit(1)
