extends Node

signal player_updated

## unlocked missions id
## eg: = 3 (missions from 0 to 3 are unlocked[inclusive])
var unlocked_missions = 0
var selected_mission = "0"
var mission_list = {
	"0" : {
		"name" : "intro",
		"file" : "res://Scenes/Levels/level_1.tscn"
	},
	"1" : {
		"name" : "hallway",
		"file" : "res://Scenes/Levels/level_1.tscn"
	},
	"2" :  {
		"name" : "reactor",
		"file" : "res://Scenes/Levels/level_2.tscn"
	},
}

#world
var camera = null
var game_time_minutes :float = 720.0
var game_time_minutes_speed := 1.0

var player = null :
	set(value):
		player = value
		emit_signal("player_updated")


var level_time := 0.0
var level_time_started := false


func _process(delta):
	game_time_minutes += delta * game_time_minutes_speed
	if level_time_started:
		level_time += delta


func reset_level_time():
	level_time = 0.0
func start_level_time():
	level_time_started = true
func stop_level_time():
	level_time_started = false

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

## format time to mm:ss:ms (parameter is seconds)
func format_time_mm_ss_ms(seconds):
	var minutes = int(seconds / 60)
	var remainingSeconds = int(fmod(seconds, 60.0))
	var milliseconds = int((seconds - int(seconds)) * 1000)
	return str(minutes).pad_zeros(2) + ":" + str(remainingSeconds).pad_zeros(2) + ":" + str(milliseconds).pad_zeros(3)

func get_level_info():
	var game = get_tree().get_node_or_null("Game")
	if game != null:
		var level_info = game.get_level_info()
