extends Node2D

var texture = preload("res://icon.svg")
@onready var icon_button: Node2D = $IconButton


func _ready() -> void:
	var active_colors = {
		"bg": Color("000055"),
		"icon": Color("AAFFFF")
	}
	var inactive_colors = {
		"bg": Color("000055"),
		"icon": Color("AAAAFF")
	}
	icon_button.init(texture, active_colors, inactive_colors)
