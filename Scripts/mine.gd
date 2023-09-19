extends Area2D


var is_armed := true
var knockback_force := 120.0
var damage := 200.0
@onready var collision_shape :=$CollisionShape2D
@onready var explosion_area := $ExplosionArea
@onready var explosion_light := $ExplosionLight
@onready var explosion_effect := $ExplosionEffect
var explosion_light_tween
func _ready():
	explosion_light_tween = create_tween()
	explosion_light_tween.kill()
	connect("body_entered", on_body_enter)
	


func _process(_delta):
	pass

func on_body_enter(_body):
	is_armed = false
	Global.camera.shake(10, 1.0)
	explosion_effect.emitting = true
	$Sprite2D.visible = false
	explosion_light.energy = 10.0
	explosion_light.enabled = true
	explosion_light_tween.kill()
	explosion_light_tween = create_tween()
	explosion_light_tween.tween_property(explosion_light,"energy", 0.0, 0.2)
	explosion_light_tween.tween_callback(func():
		explosion_light.enabled = false
		)
	for body in explosion_area.get_overlapping_bodies():
		if "health" in body:
			body.health -= damage
		if body is RigidBody2D:
			body.apply_impulse(Vector2.from_angle(global_rotation - PI * 0.5) * knockback_force)
	collision_shape.set_deferred("disabled", true)
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
