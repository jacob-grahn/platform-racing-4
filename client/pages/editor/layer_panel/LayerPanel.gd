extends Node2D

const LAYER = preload("res://layers/Layer.tscn")
const LAYER_ROW = preload("res://pages/editor/layer_panel/LayerRow.tscn")

var layers: Node2D
@onready var row_holder = $ScrollContainer/RowHolder


func _ready():
	pass


func set_layers(layers_: Node2D) -> void:
	layers = layers_
	render()


func render() -> void:
	clear()
	var layer_array = layers.get_children()
	for layer in layer_array:
		var row = LAYER_ROW.instantiate()
		row.position.y = row_holder.get_child_count() * 50
		row.get_node("Label").text = layer.name
		row_holder.add_child(row)


func clear() -> void:
	for child in row_holder.get_children():
		child.queue_free()
