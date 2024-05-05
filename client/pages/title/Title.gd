extends Node2D


func _ready():
	Jukebox.play('noodle-town-4')
	$Voter.init('2024/05/05', ['Barely functional level editor', 'Barely playable "game"', 'Beautify PR4 Logo on title page'])
