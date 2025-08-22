extends Control

signal name_change

@onready var new_layer_name = $NewLayerName
@onready var ok_button = $OKButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ok_button.connect("pressed", _set_new_name)

func _set_new_name():
	if !new_layer_name.text.is_empty():
		emit_signal("name_change", new_layer_name.text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
