extends Area2D

var damage := 30.0
var knockback_force := 50.0
@export var turn_speed := 10.0
@onready var sprite := $Sprite2D
var damage_delay := 0.03
var damage_timer_t := 0.0
@onready var disposable_effect_generator := $DisposableEffectGenerator
func _ready():
	pass

func _process(delta):
	sprite.global_rotation += turn_speed * delta

func _physics_process(delta):
	if damage_timer_t > damage_delay:
		damage_timer_t -= damage_delay
		damage_surrounding()
	damage_timer_t += delta
func damage_surrounding():
	for body in get_overlapping_bodies():
		var collision_dir = (body.global_position - global_position).normalized()
		var collision_point = global_position + (body.global_position - global_position)
		if "health" in body:
			body.health -= damage
			disposable_effect_generator.spawn_effect("sparks", collision_point, collision_dir.angle())
		if body is RigidBody2D:
			var force_dir = (body.global_position - global_position).normalized()
			body.apply_impulse(force_dir * knockback_force)
			body.apply_torque_impulse(turn_speed * 10)
