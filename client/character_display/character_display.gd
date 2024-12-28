class_name CharacterDisplay
extends Node2D


func _ready() -> void:
	pass # Replace with function body.


func set_style(character_config: Dictionary) -> void:
	# colors
	get_node("Head/Color").modulate = Color(character_config["head"]["color"])
	get_node("Body/Color").modulate = Color(character_config["body"]["color"])
	get_node("FootFront/Color").modulate = Color(character_config["feet"]["color"])
	get_node("FootBack/Color").modulate = Color(character_config["feet"]["color"])
