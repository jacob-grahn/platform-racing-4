extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/05/10', ['Crouch under tight spots', 'New block: it is a mystery!', 'Break bricks with your head of course'])
	$GameButton.pressed.connect(_on_game_pressed)


func _on_game_pressed():
	Game.pr2_level_id = $TextEdit.text
	Helpers.set_scene("GamePage")
