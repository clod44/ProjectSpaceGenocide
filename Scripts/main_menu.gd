extends CanvasLayer

@export var console_output : RichTextLabel
@export var console_input : TextEdit
@export var btn_enter : Button

var game_scene = preload("res://Scenes/game.tscn")

var command_library= {
	"v": {
		"description": "version of the firmware",
		"function": 
			func():
				cout("v1.0"),
},
	"missionstart": {
		"description": "ejects the worker into the specified section of the mission",
		"function": 
			func():
				if Global.selected_mission in Global.mission_list.keys():
					get_tree().change_scene_to_packed(game_scene)
				else:
					cout("current mission id is invalid : " + Global.selected_mission)
},
	"mission": {
		"description": "currently selected mission",
		"function": 
			func():
				cout("current mission id: "+str(Global.selected_mission))
},
	"missionlist": {
		"description": "list of missions",
		"function": 
			func():
				cout("missions:")
				for mission_id in Global.mission_list.keys():
					if int(mission_id) > Global.unlocked_missions:
						break
					cout(str(mission_id) + " = " + Global.mission_list[mission_id].name)
},
	"missionselect": {
		"description": "list of missions",
		"args" : "mission_id",
		"function": 
			func(id):
				if id in Global.mission_list.keys():
					Global.selected_mission = id
					cout("mission selected : "+ id +" = " + Global.mission_list[id].name)
				else:
					cout("there was an error selecting your mission : '"+id+"'")
},
	"logout": {
		"description": "logout from device",
		"function": 
			func():
				get_tree().quit()
}
}

func _ready():

	btn_enter.connect("pressed", on_btn_enter_press)

func _process(delta):
	pass

func enter_commands():
	var command = console_input.text.strip_edges(true, true).to_lower().split(" ")
	console_input.text = ""
	cout(command[0], ":")
	
	if command[0] == "help":
		for current_command in command_library.keys():
			cout("", "")
			cout(current_command, "command : ")
			cout(command_library[current_command].description, "*")
	elif command_library.has(command[0]):
		command_library[command[0]].function.callv(command.slice(1, command.size()))

func cout(text = "", _prefix = ">>"):
	if console_output == null:
		return
	console_output.text += "\n " + _prefix + " " + str(text)

func on_btn_enter_press():
	enter_commands()
