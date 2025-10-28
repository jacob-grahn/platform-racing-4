extends Node

var off_volume_db = -30
var on_volume_db = 0
var db_per_sec = 30
var music_volume_db = 0
var music_target_db = 0
var music_current_stream = null
var music_next_stream = null
var stop_music: bool = false
var mute_music: bool = false
var end_music: bool = false
var loop_music: bool = true
var sound_volume_db = 0
var sound_target_db = 0
var sound_current_stream = null
var sound_next_stream = []
var stop_sound: bool = false
var mute_sound: bool = false
var song_url: String = ''
var sound_url: String = ''
var song_id: String = ''
var audio_loader = AudioLoader.new()
var load_from_url: bool = false
var base_url = "http://files.platformracing.com/music"
var music_list = {}
var sound_list = {}
var local_music_list = {}
var local_sound_list = {}
var music_audio: AudioStreamPlayer
var sound_audio: AudioStreamPlayer
var sound_playback: AudioStreamPlaybackPolyphonic
var sound_polyphonic: AudioStreamPolyphonic
var song_request: HTTPRequest
var sound_request: HTTPRequest
var song_list_request: HTTPRequest
var sound_list_request: HTTPRequest


func _ready():
	local_music_list = parse_list("res://singletons/jukebox/00_music_list.json")
	local_sound_list = parse_list("res://singletons/jukebox/00_sound_list.json")
	music_audio = AudioStreamPlayer.new()
	music_audio.name = "MusicPlayer"
	sound_audio = AudioStreamPlayer.new()
	sound_audio.max_polyphony = 32
	sound_audio.name = "SoundPlayer"
	song_request = HTTPRequest.new()
	sound_request = HTTPRequest.new()
	song_list_request = HTTPRequest.new()
	sound_list_request = HTTPRequest.new()
	add_child(music_audio)
	add_child(sound_audio)
	sound_polyphonic = AudioStreamPolyphonic.new()
	sound_audio.stream = sound_polyphonic
	sound_audio.play()
	sound_playback = sound_audio.get_stream_playback()
	# song_list is not same as local song list so it is disabled as of now
	# also sound_list does not exist on server yet
	# add_child(song_request)
	# add_child(sound_request)
	# add_child(song_list_request)
	# add_child(sound_list_request)
	# song_request.request_completed.connect(_song_request_completed)
	# sound_request.request_completed.connect(_sound_request_completed)
	# song_list_request.request_completed.connect(_song_list_request_completed)
	# song_list_request.request(base_url + "/00_music_list.json")
	# sound_list_request.request_completed.connect(_sound_list_request_completed)
	# sound_list_request.request(base_url + "/00_sound_list.json")


func parse_list(list_location: String) -> Dictionary:
	var list_string = FileAccess.get_file_as_string(list_location)
	var json = JSON.new()
	var list_data = json.parse_string(list_string)
	if list_data:
		print("Jukebox::_ready() - file (" + list_location + ") obtained successfully!")
		return list_data
	else:
		print("Jukebox::_ready() - failed to get list from (" + list_location + ") :(")
		return {}


func play_song(slug: String, interrupt_current_song: bool = false):
	# keep track of the current song
	song_id = slug
	
	# pick a random slug if input slug is empty or set to random
	if slug == "" or slug == "random":
		var keys
		if load_from_url:
			keys = music_list.keys()
		else:
			keys = local_music_list.keys()
		slug = keys[randi() % keys.size()]
	
	# load_from_url is off because it won't work with current music list
	# until server's music list is updated.
	
	# map slug to a url if told to load from url
	# otherwise load from the game files.
	if load_from_url:
		var song_info = music_list.get(slug)
		if song_info:
			var next_url: String = base_url + "/" + song_info.file
	
			# exit early if asked to play the same song
			if song_url == next_url:
				return
	
			# otherwise get ready for a new song
			song_url = next_url
			var filepath = _song_url_to_file(next_url)
	
			# ensure a "songs" directory exists
			if (!DirAccess.dir_exists_absolute("user://songs")):
				DirAccess.make_dir_absolute("user://songs")
	
			# load file from disk if present
			if (FileAccess.file_exists(filepath)):
				play_song_file(filepath)
				end_music = true
	
			# otherwise load from url
			else:
				song_request.cancel_request()
				song_request.download_file = filepath
				song_request.request(next_url)
	else:
		var song_info = local_music_list.get(slug)
		if song_info:
			var song_location: String
		
			# get a file directly from the "songs" folder in the game (not %appdata%)
			if (DirAccess.dir_exists_absolute("res://songs")):
				song_location = "res://songs/" + song_info.file
	
			# try to load file from disk
			if song_info and song_location and (FileAccess.file_exists(song_location)):
				play_song_file(song_location)
				end_music = true
				if interrupt_current_song:
					stop_music = true


func play_song_file(filepath: String):
	music_volume_db = 0
	music_target_db = 0
	music_next_stream = audio_loader.loadfile(filepath)


func play_sound(slug: String):
	if load_from_url:
		var sound_info = sound_list.get(slug)
		if sound_info:
			var next_url: String = base_url + "/" + sound_info.file

			# get ready for a new sound
			sound_url = next_url
			var filepath = _sound_url_to_file(next_url)

			# ensure a "sounds" directory exists
			if (!DirAccess.dir_exists_absolute("user://sounds")):
				DirAccess.make_dir_absolute("user://sounds")

			# load file from disk if present
			if (FileAccess.file_exists(filepath)):
				play_sound_file(filepath)

			# otherwise load from url
			else:
				sound_request.cancel_request()
				sound_request.download_file = filepath
				sound_request.request(next_url)
	else:
		var sound_info = local_sound_list.get(slug)
		if sound_info:
			var sound_location: String

			# get a file directly from the "songs" folder in the game (not %appdata%)
			if (DirAccess.dir_exists_absolute("res://sounds")):
				sound_location = "res://sounds/" + sound_info.file

			# try to load file from disk
			if sound_info and sound_location and (FileAccess.file_exists(sound_location)):
				play_sound_file(sound_location)


func play_sound_file(filepath: String):
	sound_volume_db = 0
	sound_target_db = 0
	sound_next_stream.push_back(audio_loader.loadfile(filepath))


func stop_song(immediately: bool = false):
	if immediately:
		stop_music = true
	else:
		end_music = true
	music_target_db = off_volume_db


func fade_music(target_fade = 0):
	target_fade = clamp(target_fade, 0, 100)
	if target_fade == 0:
		music_target_db = off_volume_db
	else:
		music_target_db = off_volume_db - (off_volume_db * (target_fade / 100))


func _song_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print(song_url + " couldn't be downloaded. Result: " + str(result))
		return
		
	print(song_url + " download complete!")
	play_song_file(_song_url_to_file(song_url))


func _sound_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print(sound_url + " couldn't be downloaded. Result: " + str(result))
		return
		
	print(sound_url + " download complete!")
	play_sound_file(_sound_url_to_file(sound_url))


func _song_list_request_completed(result, response_code, headers, body):
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


func _sound_list_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Jukebox::_list_request_completed - sound list couldn't be downloaded. Result: " + str(result))
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		print("Jukebox::_list_request_completed - json parse error: ", error)
		return
	
	sound_list = json.data
	print("Jukebox::_list_request_completed - sound list downlaoded successfully!")


func _song_url_to_file(url: String) -> String:
	# Split the URL by the "/" character
	var parts = url.split("/")
	# Return the last part of the split array
	return "user://songs/" + parts[-1]


func _sound_url_to_file(url: String) -> String:
	# Split the URL by the "/" character
	var parts = url.split("/")
	# Return the last part of the split array
	return "user://sounds/" + parts[-1]


func _process(delta):
	# process music
	if music_volume_db != music_target_db:
		if music_volume_db < music_target_db:
			if music_volume_db + (db_per_sec * delta) < music_target_db:
				music_volume_db += db_per_sec * delta
			else:
				music_volume_db = music_target_db
		if music_volume_db > music_target_db:
			if music_volume_db + (db_per_sec * delta) > music_target_db:
				music_volume_db -= db_per_sec * delta
			else:
				music_volume_db = music_target_db
	
	if (end_music and music_volume_db <= off_volume_db) or stop_music:
		music_audio.stop()
		music_current_stream = null
		stop_music = false
		end_music = false
	
	if !music_current_stream and music_next_stream:
		music_audio.stream = music_next_stream
		music_current_stream = music_next_stream
		music_next_stream = null
		music_audio.play()
	
	if mute_music:
		music_audio.volume_db = off_volume_db
	else:
		music_audio.volume_db = music_volume_db

	# process sound
	if sound_volume_db != sound_target_db:
		if sound_volume_db < sound_target_db:
			if sound_volume_db + (db_per_sec * delta) < sound_target_db:
				sound_volume_db += db_per_sec * delta
			else:
				sound_volume_db = sound_target_db
		if sound_volume_db > sound_target_db:
			if sound_volume_db + (db_per_sec * delta) > sound_target_db:
				sound_volume_db -= db_per_sec * delta
			else:
				sound_volume_db = sound_target_db
	
	if stop_sound:
		sound_audio.stop()
		sound_current_stream = null
		stop_sound = false
	
	if !sound_next_stream.is_empty():
		for sound in sound_next_stream.size():
			sound_current_stream = sound_next_stream[0]
			sound_current_stream.loop = false
			sound_playback.play_stream(sound_current_stream)
			sound_next_stream.remove_at(0)
		sound_current_stream = null
	
	if mute_sound:
		sound_audio.volume_db = off_volume_db
	else:
		sound_audio.volume_db = sound_volume_db
