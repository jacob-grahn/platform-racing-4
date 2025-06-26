extends Node2D

@onready var name_panel = $NamePanel
@onready var name_label = $NamePanel/NameLabel
@onready var cursor_icon = $CursorIcon
@onready var block_icon = $BlockIcon


func initialise(userID: String):
	name_label.text = userID
	
	if userID == Globals.Session.get_username():
		name_panel.hide()
		cursor_icon.hide()


func set_block_icon(block_id: int, tile_width: int = 128, tile_height: int = 128, columns: int = 10) -> void:
	const erase_block_id = 0
	if block_id == erase_block_id:
		block_icon.hide()
		return
	
	block_icon.show()
	var row = (block_id - 1) / columns
	var column = (block_id - 1) % columns
	
	var x = column * tile_width
	var y = row * tile_height
	
	block_icon.region_rect = Rect2(x, y, tile_width, tile_height)
	block_icon.region_enabled = true
