extends Node

signal player_updated

#world
var camera = null

var game_time_minutes :float = 720.0
var game_time_minutes_speed := 1.0

var player = null :
	set(value):
		player = value
		emit_signal("player_updated")


func _process(delta):
	game_time_minutes += delta * game_time_minutes_speed
	
#formatting time
func format_time_24(minutes= null):
	if minutes == null:
		minutes = Global.game_time_minutes
	var hours = get_hours_24(minutes)
	var mins = int(fmod(minutes, 60.0))
	var formatted_hours = str(hours).pad_zeros(2)
	var formatted_mins = str(mins).pad_zeros(2)
	return formatted_hours + ":" + formatted_mins

func get_hours_24(minutes=null):
	if minutes != null:
		return int(fmod(minutes / 60.0, 24.0))
	else:
		return int(fmod(game_time_minutes / 60.0, 24.0))


