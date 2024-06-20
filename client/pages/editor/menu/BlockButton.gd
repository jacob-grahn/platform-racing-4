extends SliderItem

signal pressed

@onready var button = $Content/Button
@onready var sprite = $Content/Sprite
var block_id: int


func _ready():
	super._ready()
	button.connect("pressed", _on_pressed)


func set_block_id(id: int) -> void:
	block_id = id
	var coords = Helpers.to_atlas_coords(block_id)
	sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)
	

func _on_pressed() -> void:
	emit_signal("pressed", block_id)
