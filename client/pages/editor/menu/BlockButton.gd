extends SliderItem

signal pressed

@onready var button = $Content/Button
@onready var sprite = $Content/Sprite


func _ready():
	super._ready()
	button.connect("pressed", _on_pressed)


func set_block_id(id: int) -> void:
	var coords = Helpers.to_atlas_coords(id)
	sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)
	

func _on_pressed() -> void:
	emit_signal("pressed")
