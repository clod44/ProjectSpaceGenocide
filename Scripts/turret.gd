extends RigidBody2D

var health := 100.0
var damage = 10.0
@onready var head := $Head
@onready var scan_timer := $ScanTimer
var scan_cooldown := 1.0
@onready var scan_light := $ScanLight
var scan_light_tween

var head_turn_speed := 10.0
var head_turn_damping := 0.9
var head_angular_vel := 0.0
@onready var attack_area := $AttackArea
var target = null

var knockback_force = 100.0
@onready var shoot_ray := $Head/ShootRay
@onready var shoot_cooldown_timer := $ShootCooldown
var shoot_cooldown := 1.0
@onready var shoot_effect := $Head/ShootEffect
@onready var shoot_light := $Head/ShootLight
var shoot_light_tween

@onready var reach_test_ray := $AttackArea/ReachTestRay
func _ready():
	scan_light_tween = create_tween()
	scan_light_tween.kill()
	shoot_light_tween = create_tween()
	shoot_light_tween.kill()
	shoot_cooldown_timer.wait_time = shoot_cooldown
	scan_timer.wait_time = scan_cooldown
	scan_timer.connect("timeout", scan)
	# wait some random amount of time and start the scanning loop
	await get_tree().create_timer(scan_cooldown).timeout
	scan_timer.autostart = true
	scan_timer.start()


func _physics_process(delta):
	if is_instance_valid(target):
		var is_looking = look_towards(target.global_position, delta)
		if is_looking:
			shoot()
	else:
		look_towards(null, delta)


func shoot():
	if shoot_cooldown_timer.is_stopped():
		shoot_cooldown_timer.start()
		
		Global.camera.shake(5,1)
		shoot_effect.emitting = true
		shoot_light.energy = 1.0
		shoot_light.enabled = true
		shoot_light_tween.kill()
		shoot_light_tween = create_tween()
		shoot_light_tween.tween_property(shoot_light,"energy", 0.0, 0.2)
		shoot_light_tween.tween_callback(func():
			shoot_light.enabled = false
			)
		var node = shoot_ray.get_collider()
		if is_instance_valid(node) and "health" in node:
			node.health -= damage
			if node is RigidBody2D:
				var knockback_vector = Vector2.from_angle(shoot_ray.global_rotation) * knockback_force
				node.apply_impulse(knockback_vector)

func look_towards(pos, delta):
	var is_looking = false
	if pos != null:
		# Calculate the direction from the propeller to the target position
		var direction = (pos - head.global_position).normalized()

		# Calculate the angle in radians from the direction vector
		var angle = atan2(direction.y, direction.x)

		# Convert the angle to degrees
		var angle_degrees = angle * 180.0 / PI

		# Calculate the difference between the current rotation and the angle
		var angle_difference = angle_degrees - head.global_rotation_degrees

		# Wrap the angle difference to the range of -180 to 180 degrees
		if angle_difference > 180.0:
			angle_difference -= 360.0
		elif angle_difference < -180.0:
			angle_difference += 360.0

		# Check if the angle difference is within the specified error margin
		is_looking = abs(angle_difference) <= 10.0
		
		# Calculate the angular velocity based on the angle difference
		head_angular_vel += clamp(angle_difference, -1.0, 1.0) * head_turn_speed
	head.global_rotation_degrees += head_angular_vel * delta
	head_angular_vel *= head_turn_damping

	return is_looking

func scan():
	
	target = null
	for body in attack_area.get_overlapping_bodies():
		if "health" in body:
			reach_test_ray.target_position = body.global_position - reach_test_ray.global_position
			reach_test_ray.force_raycast_update()
			var first_reach = reach_test_ray.get_collider()
			if first_reach == body:
				target = body
			
	scan_light_tween.kill()
	scan_light_tween = create_tween()
	scan_light.modulate = Color(1.0, 1.0, 1.0, 1.0)
	scan_light_tween.tween_property(scan_light, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
