extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/05/13', ['speed / traction / jump sliders', 'Crouch under tight spots again, this one almost won', 'Another new block! Double mysterious...'])
	$GameButton.pressed.connect(_on_game_pressed)
	$GearButton.pressed.connect(_on_gear_pressed)


func _on_game_pressed():
	Game.pr2_level_id = $TextEdit.text
	Helpers.set_scene("GamePage")


func _on_gear_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("GamePage")
