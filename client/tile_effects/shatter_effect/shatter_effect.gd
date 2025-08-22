extends Node2D

var chunk_size = Vector2i(42, 42)
var chunk_linear_velocity = 300
var chunk_angular_velocity = 20


func add_pieces(atlas: Texture, coords: Vector2i, pieces) -> void:
	for i in range(0, pieces):
		var randi = randi_range(0, 9)
		var offset = Vector2i(randi % 3, randi / 3) * chunk_size
		add_piece(atlas, coords, offset, chunk_size)


func add_piece(atlas: Texture, coords: Vector2i, offset: Vector2i, dimensions: Vector2i):
	var sprite = Sprite2D.new()
	sprite.texture = atlas
	sprite.region_enabled = true
	sprite.region_rect = Rect2i((coords * Settings.tile_size) + offset, dimensions)
	
	var chunk = RigidBody2D.new()
	chunk.position = Vector2(offset)
	chunk.angular_velocity = randf_range(-chunk_angular_velocity, chunk_angular_velocity)
	chunk.linear_velocity = Vector2(randf_range(-chunk_linear_velocity, chunk_linear_velocity), randf_range(-chunk_linear_velocity, chunk_linear_velocity))
	chunk.add_child(sprite)
	
	add_child(chunk)
