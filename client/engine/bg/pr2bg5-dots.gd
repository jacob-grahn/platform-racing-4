extends Node2D

@onready var dot_sprite = preload("res://engine/bg/pr2bg5-dots-dot.svg")


func _ready() -> void:
	var dotxcounter: int = 0
	var dotycounter: int = 0
	var bg_position: Vector2 = Vector2((550 / 2), (400 / 2))
	for i in range(88):
		var newdot = Sprite2D.new()
		newdot.offset = Vector2(12.5, 12.5)
		newdot.global_position = Vector2((7.5 + (50 * (dotxcounter))) - bg_position.x, (7.5 + (50 * (dotycounter))) - bg_position.y)
		newdot.name = "Dot" + str(i + 1)
		newdot.texture = dot_sprite
		newdot.modulate = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		add_child(newdot)
		if dotxcounter >= 10:
			dotycounter += 1
			dotxcounter = 0
		else:
			dotxcounter += 1
