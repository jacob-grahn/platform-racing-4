extends Control
class_name Main

static var FILE_URL = "https://files.platformracing.com"
static var instance: Main

# page names
const TITLE = "TITLE"
const CREDITS = "CREDITS"
const LEVEL_EDITOR = "LEVEL_EDITOR"
const GAME = "GAME"
const LOBBY = "LOBBY"
const SOLO = "SOLO"
const TESTER = "TESTER"
const CHARACTER_EDITOR = "CHARACTER_EDITOR"

var scenes = {
	TITLE: preload("res://pages/title/title.tscn"),
	CREDITS: preload("res://pages/credits/credits.tscn"),
	LEVEL_EDITOR: preload("res://pages/level_editor/level_editor.tscn"),
	GAME: preload("res://pages/game/game.tscn"),
	LOBBY: preload("res://pages/level_lists/lobby.tscn"),
	SOLO: preload("res://pages/solo/solo.tscn"),
	TESTER: preload("res://pages/tester/tester.tscn"),
	CHARACTER_EDITOR: preload("res://pages/character_editor/character_editor.tscn")
}



@onready var game_client: Node2D = $GameClient
var current_scene: Node


func _ready():
	Main.instance = self
	if "--run-tests" in OS.get_cmdline_args():
		_run_tests()
		return

	
	await set_scene(TITLE)


func _run_tests():
	# Load the game scene and let it run for a few seconds
	Game.pr2_level_id = "50815"
	await _set_scene(GAME)
	await get_tree().create_timer(3.0).timeout

	# Unload the game scene and load the level editor
	var level_editor = await _set_scene(LEVEL_EDITOR)
	await get_tree().process_frame
	await get_tree().create_timer(3.0).timeout
	
	# Click the test button
	await level_editor._on_test_pressed()
	await get_tree().create_timer(3.0).timeout

	# Quit the application
	get_tree().quit()


static func set_scene(scene_name: String, data: Dictionary = {}) -> Node:
	if !instance:
		return null
	return await instance._set_scene(scene_name, data)


func _set_scene(scene_name: String, data: Dictionary = {}) -> Node:
	if current_scene:
		Global.clear()
		current_scene.queue_free()
	
	await get_tree().process_frame

	current_scene = scenes[scene_name].instantiate()
	current_scene.name = scene_name
	add_child(current_scene)
	
	if current_scene.has_method("init"):
		current_scene.init(data)

	Global.spawn = current_scene
		
	return current_scene
