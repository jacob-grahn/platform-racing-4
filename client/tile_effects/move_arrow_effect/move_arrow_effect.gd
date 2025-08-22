extends Node2D

@onready var pr4arrows = $PR4Arrows
@onready var pr3desertarrows = $PR4Arrows
@onready var pr3industrialarrows = $PR4Arrows
@onready var pr3junglearrows = $PR4Arrows
@onready var pr3underwaterarrows = $PR4Arrows
@onready var pr3spacearrows = $PR4Arrows
@onready var pr2arrows = $PR4Arrows
@onready var arrow = $Arrow
var arrowdir: int
var arrowsprite: Polygon2D
var sprite_name: String


func _ready() -> void:
	if arrowdir:
		arrowsprite = pr4arrows.get_child(arrowdir)
		sprite_name = arrowsprite.name
		arrow.polygon = arrowsprite.polygon
