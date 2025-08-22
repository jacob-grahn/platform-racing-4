extends Control


@onready var yes_button = $YesButton
@onready var no_button = $NoButton
var instance: Node2D
var delete_type: String

func _ready():
	self.visible = false
	instance = null


func initialize(node, type) -> void:
	no_button.pressed.connect(_close_pressed)
	yes_button.pressed.connect(_clear)
	instance = node
	if delete_type is String:
		delete_type = type
	if instance != null and delete_type != null:
		self.visible = true

func close() -> void:
	instance = null
	self.visible = false

func _close_pressed():
	close()
	
func _clear():
	if instance != null:
		if delete_type == "clear":
			instance._on_level_load("", "")
	instance = null
	close()
