extends Node2D


var sound_groups = {}

func _ready():
	for group in get_children():
		sound_groups[group.name] = group

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func play_random_from_group(group_name = null):
	sound_groups[group_name].get_children().pick_random().play()

func play_from_group(group_name = null, sound_name = null, custom_pitch = 1.0, force_start = true):
	for audio_player in sound_groups[group_name].get_children():
		if audio_player.name == sound_name:
			audio_player.pitch_scale = custom_pitch
			if force_start:
				audio_player.play()
			elif !audio_player.is_playing():
				audio_player.play()
			

func stop_from_group(group_name = null, sound_name = null):
	for audio_player in sound_groups[group_name].get_children():
		if audio_player.name == sound_name:
			audio_player.stop()

func change_pitch(group_name = null, sound_name = null, new_pitch = 1.0):
	for audio_player in sound_groups[group_name].get_children():
		if audio_player.name == sound_name:
			audio_player.pitch_scale = new_pitch
