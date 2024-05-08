extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/05/08', ['Arrow Blocks do thier thing', 'Draw background art Lines, erasing will not work yet', 'A character other than stick-friend, probably no run, jump, etc, animations yet'])
	$GameButton.pressed.connect(_on_game_pressed)


func _on_game_pressed():
	Game.pr2_level_id = $TextEdit.text
	Helpers.set_scene("GamePage")
