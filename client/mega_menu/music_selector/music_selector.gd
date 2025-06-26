extends IconButton

var music_list := {}
var current_music_slug := ""
@onready var music_option: OptionButton = $OptionButton


func _ready() -> void:
	super._ready()
	
	# Set up icon button
	var music_texture = preload("res://mega_menu/music_selector/music_icon.png")
	init(music_texture, active_colors, inactive_colors)
	
	# Add music to option button
	music_list = Globals.Jukebox.music_list
	for slug in music_list:
		var music_info = music_list[slug]
		var label = music_info.title + " by " + music_info.composer
		music_option.add_item(label)
		music_option.set_item_metadata(music_option.item_count - 1, slug)
	
	# Connect signals
	music_option.item_selected.connect(_on_music_selected)


func _on_music_selected(index: int) -> void:
	current_music_slug = music_option.get_item_metadata(index)
	Globals.Jukebox.play(current_music_slug)


# Override set_active to prevent this button from being activated
func set_active(p_active: bool) -> void:
	# Do nothing - this button should never show as active
	pass
