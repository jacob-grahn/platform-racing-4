extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/05/06', ['Tripple Bow', 'Fix the seams in the scrolly background, everyone\'s day is ruined', 'PR2 level import, just blocks though no art yet'])
	$GameButton.pressed.connect(_on_game_pressed)


func _on_game_pressed():
	get_node("/root/Main").set_scene("Game")
