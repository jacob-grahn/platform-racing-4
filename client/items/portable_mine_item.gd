extends PortableBlockItem
class_name PortableMineItem


func _ready():
	PortableBlock = load("res://item_effects/portable_mine.tscn")
	tile_id = 45


func _init_item():
	uses = GameConfig.get_value("uses_portable_mine")


func _process(delta: float) -> void:
	if character:
		set_block_position()


func activate_item():
	if character and !using and can_place:
		using = true
		use_block()
		uses -= 1

func _remove_item():
	pass
