extends Area2D

@export var force = 20000.0

## this is here to create fancy visuals with offsetted pushing pulling effects
@export var initial_activation_delay := 0.1
@export var activation_delay := 3.0
@onready var activation_timer := $ActivationTimer
var is_working := false : 
	set(value):
		var old_value = is_working
		is_working = value
		if old_value != is_working and cpu_effect != null:
			cpu_effect.emitting = is_working
var collision_shape_radius := 1.0
@onready var cpu_effect := $CPUParticles2D

@onready var color_rect := $ColorRect
var color_rect_tween
var found_target := false :
	set(value):
		var old_value = found_target
		found_target = value
		if old_value != found_target:
			if  color_rect != null and color_rect.modulate == Color(1,1,1, 0.0) and color_rect_tween != null:
				color_rect_tween.kill()
				color_rect_tween = create_tween()
				color_rect.modulate = Color(1,1,1,1)
				color_rect_tween.tween_property(color_rect, "modulate", Color(1,1,1,0), 1.0)
func _ready():
	color_rect_tween = create_tween()
	color_rect_tween.kill()
	collision_shape_radius = $CollisionShape2D.shape.radius
	activation_timer.connect("timeout", func():
		is_working = !is_working
		)
	activation_timer.wait_time = activation_delay
	await get_tree().create_timer(initial_activation_delay).timeout
	is_working = true
	activation_timer.autostart = true
	activation_timer.start()


func _physics_process(delta):
	found_target = false
	if is_working:
		for body in get_overlapping_bodies():
			if body is RigidBody2D:
				found_target = true
				var vec = (global_position - body.global_position)
				var dist_factor = 1.0 - clamp(vec.length() / collision_shape_radius, 0, 1)
				var dir = vec.normalized()
				body.apply_force(dir * force * dist_factor * delta)
