extends Node2D

var SliderControlRow: PackedScene = preload("res://pages/editor/SliderControlRow.tscn")
var SliderBlockRow: PackedScene = preload("res://pages/editor/SliderBlockRow.tscn")

var sub_row
var sub_row_type: String


func _ready():
	var control_row = SliderControlRow.instantiate()
	control_row.connect("pressed", _on_control_pressed)
	add_row(control_row)
	
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()


func _process(delta):
	pass


func add_row(row) -> void:
	var height = get_height()
	add_child(row)
	row.position = Vector2(0, height)
	_on_size_changed()


func remove_row(row) -> void:
	remove_child(row)
	_on_size_changed()


func get_height() -> float:
	var height = 0
	for row in get_children():
		height += row.get_dimensions().y
	return height


func _on_size_changed():
	var window_size = get_viewport().get_visible_rect().size
	position = Vector2(0, window_size.y - get_height())


func _on_control_pressed(label: String) -> void:
	if sub_row_type == label:
		return
	
	if sub_row:
		remove_row(sub_row)
		sub_row = null
		
	sub_row_type = label
	
	if label == "Blocks":
		sub_row = SliderBlockRow.instantiate()
		add_row(sub_row)
