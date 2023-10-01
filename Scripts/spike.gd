extends Area2D

@export var damage := 100.0
@export var knockback := 150.0

@onready var sprite := $Sprite2D
var trap_setup_tween
var is_trap_open := true

@onready var sound_manager := $SoundManager
@onready var disposable_effect_generator := $DisposableEffectGenerator
func _ready():
	trap_setup_tween = create_tween()
	trap_setup_tween.kill()
	trap_close()
	connect("body_entered", on_body_enter)
	

func on_body_enter(body):
	if body is RigidBody2D:
		trap_open()
		
	
func trap_open():
	if is_trap_open:
		return
	is_trap_open = true
	
	sound_manager.play_from_group("All", "Spike_1", randf_range(0.9, 1.1))
	
	for body in get_overlapping_bodies():
		if body is RigidBody2D:
			body.apply_impulse(Vector2.UP.rotated(global_rotation) * knockback)
			body.apply_torque_impulse((randf() - 0.5) * 200)
			disposable_effect_generator.spawn_effect("Sparks", global_position, global_rotation - PI*0.5)
			if "health" in body:
				body.health -= damage
	
	trap_setup_tween.kill()
	trap_setup_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	trap_setup_tween.tween_property(sprite, "position", Vector2(0, -sprite.get_rect().size.y * 0.5 + 1), 0.5)
	trap_setup_tween.tween_callback(func():
		await get_tree().create_timer(0.5).timeout
		trap_close()
		)
	

func trap_close():
	if !is_trap_open:
		return
	sound_manager.play_from_group("All", "MechanicalRewind_1", randf_range(0.9, 1.1))
	trap_setup_tween.kill()
	trap_setup_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	trap_setup_tween.tween_property(sprite, "position", Vector2(0,sprite.get_rect().size.y * 0.5), 1.0)
	trap_setup_tween.tween_callback(func():
		is_trap_open = false
		sound_manager.stop_from_group("All", "MechanicalRewind_1")
		)
	
