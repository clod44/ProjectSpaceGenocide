extends CanvasLayer


@export var health_bar : ProgressBar
@export var level_time : Label
@export var level_objective : Label
@export var btn_pause : Button
var btn_pause_icons = [
	preload("res://Assets/Textures/ui/ui_pause.png"),
	preload("res://Assets/Textures/ui/ui_play.png"),
]
@export var pause_menu : VBoxContainer
var player = null

@export var btn_restart_checkpoint : Button
@export var btn_restart_level : Button
@export var btn_main_menu : Button

@export var level_select : Control
@export var level_select_visible := false :
	set(value):
		level_select_visible = value
		if level_select != null:
			level_select.visible = level_select_visible

@onready var game_node = get_parent()

func _ready():
	level_select_visible = level_select_visible
	Global.connect("player_updated", on_player_update)
	game_node.connect("level_updated", on_level_update)
	on_player_update()

	btn_pause.connect("pressed", on_btn_pause_press)
	btn_restart_checkpoint.connect("pressed", on_btn_restart_checkpoint_press)
	btn_restart_checkpoint.connect("pressed", on_btn_restart_level_press)
	btn_main_menu.connect("pressed", on_btn_main_menu_press)
	
	Global.hud = self

func on_level_update():
	level_objective.text = "Objective : "+game_node.current_level.current_level_objective
func _process(delta):
	level_time.text = Global.format_time_mm_ss_ms(Global.level_time)
	if player != null:
		health_bar.visible = true
		health_bar.value = lerp(health_bar.value, player.health, delta * 10.0)

func on_player_update():
	player = Global.player
	if player != null:
		health_bar.max_value = player.max_health
		health_bar.value = player.health
	else:
		health_bar.max_value = 1.0
		health_bar.value = 0.0

func on_btn_pause_press():
	get_tree().paused = !get_tree().paused
	if btn_pause.button_pressed:
		btn_pause.icon = btn_pause_icons[1]
		pause_menu.visible = true
	else:
		btn_pause.icon = btn_pause_icons[0]
		pause_menu.visible = false

func on_btn_restart_checkpoint_press():
	btn_pause.emit_signal("pressed")
	get_tree().paused = false # just in case
	pass

func on_btn_restart_level_press():
	btn_pause.emit_signal("pressed")
	get_tree().paused = false # just in case
	pass
	
func on_btn_main_menu_press():
	btn_pause.emit_signal("pressed")
	get_tree().paused = false # just in case
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
