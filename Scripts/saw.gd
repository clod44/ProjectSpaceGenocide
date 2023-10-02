extends Area2D

var damage := 30.0
var knockback_force := 50.0
@export var turn_speed := 10.0
@onready var sprite := $Sprite2D
var damage_delay := 0.03
var damage_timer_t := 0.0
@onready var disposable_effect_generator := $DisposableEffectGenerator
@onready var sound_manager := $SoundManager
@onready var collision_shape := $CollisionShape2D
var collision_shape_radius := 1.0
func _ready():
	sound_manager.play_from_group("All", "Idle", randf_range(0.7, 1.3))
	collision_shape_radius = collision_shape.shape.radius
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
		var collision_point = global_position + (body.global_position - global_position).limit_length(collision_shape_radius)
		if body is RigidBody2D:
			var force_dir = (body.global_position - global_position).normalized()
			body.apply_impulse(force_dir * knockback_force)
			body.apply_torque_impulse(turn_speed * 10)	
			disposable_effect_generator.spawn_effect("Sparks", collision_point, collision_dir.angle())
			sound_manager.play_from_group("All", "Cutting")
		
		if "health" in body:
			body.health -= damage
			Global.camera.shake(1.0, 2.0)
