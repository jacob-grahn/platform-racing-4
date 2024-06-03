extends Node2D

signal do_event
signal undo_event

var events = []
var redo_events = []


func add_event(event: Dictionary) -> void:
	if len(redo_events) > 0:
		redo_events = []
	events.push_back(event)
	emit_signal("do_event", event)


func undo() -> void:
	var event = events.pop_back()
	redo_events.push_back(event)
	emit_signal("undo_event", event)


func redo() -> void:
	if len(redo_events) == 0:
		return
	var event = redo_events.pop_back()
	events.push_back(event)
	emit_signal("do_event", event)
	
