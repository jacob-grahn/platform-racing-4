extends OptionButton


func _ready() -> void:
	var music_list = Jukebox.music_list
	for slug in music_list:
		var music_info = music_list[slug]
		var label = music_info.title + " by " + music_info.composer
		add_item(label)
		set_item_metadata(item_count - 1, slug)


func get_dimensions() -> Vector2:
	return size
