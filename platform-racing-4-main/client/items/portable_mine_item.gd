extends PortableBlockItem
class_name PortableMineItem


func _physics_process(delta):
	set_block_position()
	check_if_used()

func _ready():
	PortableBlock = load("res://item_effects/portable_mine.tscn")
	tile_id = 10
	set_block_position()

func check_if_used():
	if uses < 1:
		remove = true

func activate_item():
	if !using:
		using = true
		use_block()
		uses -= 1

func still_have_item():
	if !remove:
		return true
	else:
		return false
