extends Control

@onready var tile_map_mini: Node2D = $TileMapMini
@onready var player_icon: TextureRect = $PlayerIcon
@onready var character: TextureRect = $PlayerIcon
func _process(delta: float) -> void:
	var map_used_rect = tile_map_mini.get_used_rect()
	var player_position = Session.get_player_position()
	
	var player_icon_x = player_position.x - (map_used_rect.position.x * Settings.tile_size.x)
	var player_icon_y = player_position.y - ((map_used_rect.position.y + 1) * Settings.tile_size.y)
	player_icon.position = Vector2i(player_icon_x, player_icon_y)
