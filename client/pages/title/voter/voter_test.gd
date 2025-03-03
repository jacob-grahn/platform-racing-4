extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Voter.init('Do you like this test?', ['yes, I really do', 'no, this is the worst ever made', 'however ther is a need to explain more the reasons why'])
