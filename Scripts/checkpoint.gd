extends Area2D


@export var is_active := false :
	set(value):
		var old_value = is_active
		is_active = value
		if old_value != is_active and is_active and aura_light != null and flare_light != null and beep_light != null and flare_tween != null:
			flare_tween.kill()
			flare_tween = create_tween().set_trans(Tween.TRANS_CIRC)
			flare_light.enabled = true
			aura_light.enabled = true
			beep_light.modulate.a = 1.0
			flare_tween.tween_property(aura_light, "energy", 0.0, 5.0)
			flare_tween.parallel().tween_property(flare_light, "energy", 0.0, 5.0)
			flare_tween.parallel().tween_property(flare_light, "texture_scale", flare_light.texture_scale * 0.8, 5.0)
			flare_tween.tween_callback(func():
				flare_light.enabled = false
				aura_light.enabled = false
				)


@onready var flare_light := $Flare
@onready var aura_light := $Aura
@onready var beep_light := $Beep
var flare_tween
@onready var sound_manager := $SoundManager

func _ready():
	flare_tween = create_tween()
	flare_tween.kill()
	is_active = is_active
	connect("body_entered", on_body_enter)
	connect("body_exited", on_body_exit)


func on_body_enter(body):
	if !is_active and "spawn_position" in body:
		is_active = true
		sound_manager.play_from_group("All", "Checkpoint_1", randf_range(0.9, 1.1))
		body.spawn_position = global_position 
	if Global.hud != null:
		Global.hud.level_select_visible = true

func on_body_exit(body):
	if Global.hud != null and "spawn_position" in body:
		Global.hud.level_select_visible = false
	
