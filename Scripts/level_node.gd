extends Marker2D

@export var text := "?"
@export var disabled = true
@onready var button := $Button
@onready var light := $Light
@onready var sprite := $Sprite2D
@export var level_id := "0"
@onready var game_scene := preload("res://Scenes/game.tscn")
## colorrect. creates a road from this level to next level 
@onready var path := $Path
## reference of the previous level node so we can create the path
@export var next_level : Marker2D

var tween
func _ready():
	tween = create_tween()
	tween.kill()
	button.connect("pressed", on_btn_press)
	button.connect("mouse_entered", on_mouse_entered)
	button.connect("mouse_exited", on_mouse_exited)
	button.text = text
	if next_level != null:
		var vec = next_level.global_position - global_position
		path.rotation = vec.angle()
		path.size.x = vec.length()
	


func on_mouse_entered():
	light.enabled = true
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 1.0)
	tween.parallel().tween_property(button, "scale", Vector2(0.9, 0.9), 1.0)

func on_mouse_exited():
	light.enabled = false
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 1.0)
	tween.parallel().tween_property(button, "scale", Vector2.ONE, 1.0)
	

func on_btn_press():
	Global.selected_mission = level_id
	get_tree().change_scene_to_packed(game_scene)
