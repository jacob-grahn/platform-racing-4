extends SliderItem

signal pressed

@onready var button = $Content/Button
@onready var sprite = $Content/Sprite
var coords: Vector2i


func _ready():
	super._ready()
	button.connect("pressed", _on_pressed)


func set_coords(_coords: Vector2i) -> void:
	coords = _coords
	sprite.region_rect = Rect2(coords * Settings.tile_size, Settings.tile_size)
	

func _on_pressed() -> void:
	emit_signal("pressed", coords)
