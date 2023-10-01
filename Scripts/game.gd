extends Node2D

signal level_updated


var current_level = null

func _ready():
	current_level = load(Global.mission_list[Global.selected_mission].file).instantiate()
	$Level.add_child(current_level)
	emit_signal("level_updated")
	Global.player.spawn_position = current_level.get_node("InitialSpawnPosition").global_position
	Global.player.respawn_at(Global.player.spawn_position)
	Global.start_level_time()
	


func _process(_delta):
	pass

func get_level_info():
	return current_level.current_level_objective
