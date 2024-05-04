extends Node2D

var off_volume_db = -30
var on_volume_db = 0
var db_per_sec = 15
var current_song = ''
var next_song = ''
var songs = {
	"noodle-town-4" = preload("res://singletons/jukebox/noodle-town-4.ogg")
}
@onready var audio:AudioStreamPlayer = get_node("AudioStreamPlayer")


func play(song_id: String):
	next_song = song_id


func _process(delta):
	if !next_song:
		if audio.volume_db < on_volume_db:
			audio.volume_db += db_per_sec * delta
		if audio.volume_db > on_volume_db:
			audio.volume_db = on_volume_db
	
	else:
		if audio.volume_db > off_volume_db:
			audio.volume_db -= db_per_sec * delta
		if audio.volume_db <= off_volume_db:
			audio.volume_db = off_volume_db
			audio.stream = songs[next_song]
			audio.play()
			current_song = next_song
			next_song = ''
