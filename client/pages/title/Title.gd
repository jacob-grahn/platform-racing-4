extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/06/27', ['Blocks on all layers are active, kind of goofy but kind of fun', 'Blocks on the same depth as the player are active, can go from layer to layer with teleport blocks', 'Only blocks on depth 100 are active, the rest are for decoration'])
	$GameButton.pressed.connect(_on_game_pressed)
	$GearButton.pressed.connect(_on_gear_pressed)


func _on_game_pressed():
	Game.pr2_level_id = $TextEdit.text
	Helpers.set_scene("GAME")


func _on_gear_pressed():
	Game.pr2_level_id = '0'
	Helpers.set_scene("EDITOR")
