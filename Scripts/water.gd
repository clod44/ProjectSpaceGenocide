extends Area2D


@export var water_linear_damp = 5.0
@export var water_gravity_scale = 0.5
@export var water_angular_damp = 2.0
# Create a dictionary to store the properties of rigid bodies in water
var bodies_in_water = {}
@onready var collision_shape := $CollisionShape2D
@onready var water_effect := $WaterEffect

@onready var disposable_effect_generator := $DisposableEffectGenerator
@onready var sound_manager := $SoundManager
func _ready():
	water_effect.size = collision_shape.shape.size
	water_effect.global_position = collision_shape.global_position - water_effect.size * 0.5
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


func _on_body_entered(body):
	if body is RigidBody2D:
		var rigidbody = body
		
		sound_manager.play_random_from_group("Splashes", randf_range(0.9, 1.1))
		disposable_effect_generator.spawn_effect("Splash", rigidbody.global_position)

		# Store the original properties in the dictionary
		bodies_in_water[rigidbody] = {
			"original_linear_damp": rigidbody.linear_damp,
			"original_gravity_scale": rigidbody.gravity_scale,
			"original_angular_damp": rigidbody.angular_damp
		}

		# Apply water properties
		rigidbody.linear_damp = water_linear_damp
		rigidbody.gravity_scale = water_gravity_scale
		rigidbody.angular_damp = water_angular_damp

func _on_body_exited(body):
	if body is RigidBody2D and bodies_in_water.has(body):
		var rigidbody = body
		
		sound_manager.play_random_from_group("Splashes", randf_range(0.9, 1.1))
		disposable_effect_generator.spawn_effect("Splash", rigidbody.global_position)
		
		# Restore the original properties from the dictionary
		var original_properties = bodies_in_water[rigidbody]
		rigidbody.linear_damp = original_properties["original_linear_damp"]
		rigidbody.gravity_scale = original_properties["original_gravity_scale"]
		rigidbody.angular_damp = original_properties["original_angular_damp"]

		# Remove the entry from the dictionary
		bodies_in_water.erase(rigidbody)
