extends RigidBody2D


var max_health := 1000.0
var health := 1000.0 :
	set(value):
		var old_value = health
		if max_health != null:
			health = min(value, max_health)
		else:
			health = value
		if old_value > health:
			take_damage()
var health_regenation := 2.0
var roll_speed := 10000.0
var move_speed := 20000.0
var propelling_force := 40000.0
var propeller_fuel_max := 1.0
var propeller_fuel := 1.0
var propeller_refill_amount := 0.1
var propeller_usage_amount := 2.0
var jump_force := 150.0
@onready var jump_cooldown_timer := $JumpCooldown
var jump_cooldown := 0.01

@onready var propeller := $Propeller
@onready var propeller_flame := $Propeller/PropellerFlame
var is_propelling := false :
	set(value):
		var old_value = is_propelling
		is_propelling = value
		if is_propelling != old_value:
			propeller_flame.emitting = is_propelling

var move_input := 0.0
@onready var trail := $Trail
@onready var disposable_effect_generator := $DisposableEffectGenerator
var collision_shape_radius := 1.0

@onready var jump_check_area := $NonRotatingNode/JumpCheckArea
@onready var non_rotating_node := $NonRotatingNode
@onready var collision_shape := $CollisionShape2D

var spawn_position := Vector2.ZERO
var is_dead := false :
	set(value):
		var old_value = is_dead
		is_dead = value
		if old_value != is_dead:
			visible = !is_dead
			set_deferred("freeze", is_dead)
			collision_shape.set_deferred("disabled", is_dead)
			
			if is_dead:
				#Global.stop_level_time()
				if move_input != null:
					move_input = 0
					linear_velocity = Vector2.ZERO
					global_rotation = 0
					angular_velocity = 0
			
			set_process(!is_dead)

@onready var sound_manager := $SoundManager

func _ready():
	Global.player = self
	collision_shape_radius = collision_shape.shape.radius
	
func _process(_delta):
	move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	# Get the mouse position in world coordinates
	var mouse_pos = get_global_mouse_position()

	# Calculate the direction from the propeller to the mouse
	var direction = (mouse_pos - propeller.global_position).normalized()

	# Calculate the angle in radians from the direction vector
	var angle = atan2(direction.y, direction.x)

	# Convert the angle to degrees and set it as the propeller's rotation
	propeller.global_rotation_degrees = (angle * 180.0 / PI) + 270.0
	
	is_propelling = Input.is_action_pressed("propell")
	if Input.is_action_just_pressed("jump") and jump_check_area.get_overlapping_bodies().size() > 0:
		jump_cooldown_timer.start()
		sound_manager.play_random_from_group("Hits")
		apply_impulse(Vector2.UP * jump_force)
	
	trail.modulate_color.a = clamp(remap(linear_velocity.length(), 0, 1000, 0, 1), 0, 1)
	
var prev_lin_vel_length := 0.0
func _physics_process(delta):
	apply_torque(move_input * roll_speed * delta)
	apply_force(Vector2(move_input * move_speed, 0.0) * delta)
	if is_propelling and propeller_fuel -2.0 * delta >= 0.0:
		propeller_fuel -= propeller_usage_amount * delta
		apply_force(Vector2.UP.rotated(propeller.global_rotation) * propelling_force * delta)
	else:
		propeller_fuel = min(propeller_fuel + propeller_refill_amount * delta, propeller_fuel_max)
	
	var lin_vel = linear_velocity
	var lin_vel_length = lin_vel.length()
	if abs(lin_vel_length - prev_lin_vel_length) > 35.0:
		var collision_point = global_position + lin_vel.normalized() * -collision_shape_radius
		var effect_angle = (collision_point - global_position).angle() + PI
		disposable_effect_generator.spawn_effect("Smoke", collision_point, effect_angle)
	prev_lin_vel_length = lin_vel_length
	
	non_rotating_node.global_rotation = 0.0 
	
	health += health_regenation * delta

func take_damage():
	sound_manager.play_random_from_group("Hits")
	if health <= 0:	
		Global.camera.shake(1.0, 5.0)
		
		disposable_effect_generator.spawn_effect("Explosion", global_position)
		disposable_effect_generator.spawn_effect("Flashbang", global_position, randf() * TAU)
		sound_manager.play_random_from_group("Explosions")
		respawn_at(spawn_position)
		

func respawn_at(pos = Vector2.ZERO):
	is_dead = true
	await get_tree().create_timer(1.0).timeout
	health = max_health
	global_position = pos
	await get_tree().create_timer(1.0).timeout
	is_dead = false
