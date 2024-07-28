extends Node2D

var off_volume_db = -30
var on_volume_db = 0
var db_per_sec = 15
var current_stream = null
var next_stream = null
var song_url: String = ''
var audio_loader = AudioLoader.new()
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var http_request: HTTPRequest = $HTTPRequest


func play_url(url: String):
	# exit early if asked to play the same song
	if song_url == url:
		return
	
	# otherwise get ready for a new song
	song_url = url
	var filepath = _url_to_file(url)
	
	# ensure a "songs" directory exists
	if (!DirAccess.dir_exists_absolute("user://songs")):
		DirAccess.make_dir_absolute("user://songs")
	
	# load file from disk if present
	if (FileAccess.file_exists(filepath)):
		play_file(filepath)
	
	# otherwise load from url
	else:
		http_request.cancel_request()
		http_request.download_file = _url_to_file(url)
		http_request.request_completed.connect(_http_request_completed)
		http_request.request(url)


func play_file(filepath: String):
	next_stream = audio_loader.loadfile(filepath)


func _http_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		print(song_url + " downlaod complete!")
		play_file(_url_to_file(song_url))
	else:
		print(song_url + " couldn't be downloaded. Result: " + str(result))


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
