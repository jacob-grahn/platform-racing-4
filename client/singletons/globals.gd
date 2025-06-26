extends Node

var CachingLoader = preload("res://singletons/caching_loader.gd").new()
var Helpers = preload("res://singletons/helpers/helpers.gd").new()
var Session = preload("res://singletons/session/session.gd").new()
var Jukebox = preload("res://singletons/jukebox/jukebox.tscn").instantiate()

func _ready():
	add_child(Jukebox)
	Session._ready()
