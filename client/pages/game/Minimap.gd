extends Control

@onready var tile_map_mini: Node2D = $TileMapMini
@onready var player_icon: TextureRect = $PlayerIcon
@onready var character: TextureRect = $PlayerIcon

const MIN_ICON_SCALE = 1.0
const ICON_SCALE_FACTOR = 0.2
const ICON_X_OFFSET_FACTOR = 0.3
const ICON_Y_OFFSET_FACTOR = 0.5

func _process(delta: float) -> void:
	var map_used_rect = tile_map_mini.get_used_rect()
	var player_position = Session.get_player_position()
	
	player_icon.scale = Vector2(
		max(MIN_ICON_SCALE, ICON_SCALE_FACTOR / scale.x), 
		max(MIN_ICON_SCALE, ICON_SCALE_FACTOR / scale.y)
	)
	
	var player_icon_x_offset = ICON_X_OFFSET_FACTOR * player_icon.scale.x
	var player_icon_y_offset = ICON_Y_OFFSET_FACTOR * player_icon.scale.y
	
	var player_icon_x = player_position.x - ((map_used_rect.position.x + player_icon_x_offset) * Settings.tile_size.x)
	var player_icon_y = player_position.y - ((map_used_rect.position.y + player_icon_y_offset) * Settings.tile_size.y)
	player_icon.position = Vector2(player_icon_x, player_icon_y)
