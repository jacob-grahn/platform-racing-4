extends Node2D

@onready var name_label = $NamePanel/NameLabel

func initialise(userID: String):
	if name_label:
		name_label.text = userID
