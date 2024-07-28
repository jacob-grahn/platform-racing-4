extends Node2D


func _ready():
	Jukebox.play_url("https://tunes.platformracing.com/noodletown-4-remake-by-damon-bass.mp3")
	$Voter.init('2024/07/28', ['Just make all of the PR2 blocks work', 'Add a couple of new blocks', 'Save and share levels'])
	$GameButton.pressed.connect(_on_game_pressed)
	$GearButton.pressed.connect(_on_gear_pressed)


func _on_game_pressed():
	Game.pr2_level_id = $TextEdit.text
	Helpers.set_scene("GAME")


func _on_gear_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("EDITOR")
