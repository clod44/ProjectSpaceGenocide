extends Control



var level_select_buttons := []

func _ready():
	for level_select_button in $ScrollContainer/Levels.get_children():
		level_select_button.pressed.connect(on_level_button_pressed.bind(level_select_button))
		level_select_buttons.append(level_select_button)
		

func _process(_delta):
	pass


func on_level_button_pressed(button):
	Global.selected_mission = button.get_tooltip()
	get_tree().change_scene_to_packed(Global.game_scene)
