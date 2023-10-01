extends Area2D


var is_armed := true
var knockback_force := 150.0
var damage := 200.0
@onready var collision_shape :=$CollisionShape2D
@onready var explosion_area := $ExplosionArea
@onready var sound_manager := $SoundManager
@onready var disposable_effect_generator := $DisposableEffectGenerator
func _ready():
	connect("body_entered", on_body_enter)
	


func _process(_delta):
	pass

func on_body_enter(_body):
	is_armed = false
	Global.camera.shake(2.0, 4.0)
	$Sprite2D.visible = false
	disposable_effect_generator.spawn_effect("ExplosionEffect", global_position, global_rotation)
	disposable_effect_generator.spawn_effect("Flashbang", collision_shape.global_position, randf()*TAU)
	for body in explosion_area.get_overlapping_bodies():	
		if body is RigidBody2D:
			body.apply_impulse(Vector2.from_angle(global_rotation - PI * 0.5) * knockback_force)
		if "health" in body:
			body.health -= damage
	collision_shape.set_deferred("disabled", true)
	sound_manager.play_from_group("Explosion", "Explosion_1", randf_range(0.6, 1.4))
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
