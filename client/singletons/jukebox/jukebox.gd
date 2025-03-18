extends Node2D

var off_volume_db = -30
var on_volume_db = 0
var db_per_sec = 15
var current_stream = null
var next_stream = null
var song_url: String = ''
var song_id: String = ''
var audio_loader = AudioLoader.new()
var base_url = "http://files.platformracing.com/music"
var music_list = {
	"noodletown-4-remake": {
		"title": "Noodletown 4 Remake",
		"composer": "Damon Bass",
		"file": "noodletown-4-remake-by-damon-bass.mp3",
		"group": "2024"
	}
}
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var song_request: HTTPRequest = $SongRequest
@onready var list_request: HTTPRequest = $ListRequest


func _ready():
	song_request.request_completed.connect(_song_request_completed)
	list_request.request_completed.connect(_list_request_completed)
	list_request.request(base_url + "/00_music_list.json")


func play(slug: String):
	
	# keep track of the current song
	song_id = slug
	
	# pick a random slug if input slug is empty
	if slug == "":
		var keys = music_list.keys()
		slug = keys[randi() % keys.size()]
	
	# map slug to a url
	var song_info: Dictionary = music_list.get(slug, music_list["noodletown-4-remake"])
	var next_url: String = base_url + "/" + song_info.file
	
	# exit early if asked to play the same song
	if song_url == next_url:
		return
	
	# otherwise get ready for a new song
	song_url = next_url
	var filepath = _url_to_file(next_url)
	
	# ensure a "songs" directory exists
	if (!DirAccess.dir_exists_absolute("user://songs")):
		DirAccess.make_dir_absolute("user://songs")
	
	# load file from disk if present
	if (FileAccess.file_exists(filepath)):
		play_file(filepath)
	
	# otherwise load from url
	else:
		song_request.cancel_request()
		song_request.download_file = filepath
		song_request.request(next_url)


func play_file(filepath: String):
	next_stream = audio_loader.loadfile(filepath)


func _song_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print(song_url + " couldn't be downloaded. Result: " + str(result))
		return
		
	print(song_url + " downlaod complete!")
	play_file(_url_to_file(song_url))


func _list_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Jukebox::_list_request_completed - song list couldn't be downloaded. Result: " + str(result))
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Jukebox::_list_request_completed - json parse error: ", error)
		return
	
	music_list = json.data
	print("Jukebox::_list_request_completed - song list downlaoded successfully!")


func _url_to_file(url: String) -> String:
	# Split the URL by the "/" character
	var parts = url.split("/")
	# Return the last part of the split array
	return "user://songs/" + parts[-1]


func _process(delta):
	if !next_stream:
		if audio.volume_db < on_volume_db:
			audio.volume_db += db_per_sec * delta
		if audio.volume_db > on_volume_db:
			audio.volume_db = on_volume_db
	
	else:
		if audio.volume_db > off_volume_db:
			audio.volume_db -= db_per_sec * delta
		if audio.volume_db <= off_volume_db:
			audio.volume_db = off_volume_db
			audio.stream = next_stream
			audio.play()
			current_stream = next_stream
			next_stream = null
