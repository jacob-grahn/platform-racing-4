extends PanelContainer

signal control_event

@onready var grid_container = $MarginContainer/ScrollContainer/GridContainer

var line_edit_nodes: Dictionary = {}


func _ready():
	hide()
	populate_options()


func populate_options():
	for key in GameConfig.default_values:
		var label = Label.new()
		label.text = key.replace("_", " ").capitalize()
		grid_container.add_child(label)

		var default_label = Label.new()
		default_label.text = str(GameConfig.default_values[key])
		grid_container.add_child(default_label)

		var line_edit = LineEdit.new()
		line_edit.name = key
		line_edit.text = str(GameConfig.get_value(key))
		line_edit.connect("text_changed", Callable(self, "_on_text_changed").bind(key))
		grid_container.add_child(line_edit)
		line_edit_nodes[key] = line_edit


func _on_text_changed(new_text: String, key: String):
	var default_value = GameConfig.default_values[key]
	var new_value

	if new_text.is_empty():
		GameConfig.override_values.erase(key)
		return

	if default_value is float:
		new_value = new_text.to_float()
	elif default_value is int:
		new_value = new_text.to_int()
	else:
		new_value = new_text

	if new_value == default_value:
		GameConfig.override_values.erase(key)
	else:
		GameConfig.override_values[key] = new_value


func toggle():
	if visible:
		hide()
	else:
		show()
		for key in line_edit_nodes:
			line_edit_nodes[key].text = str(GameConfig.get_value(key))
