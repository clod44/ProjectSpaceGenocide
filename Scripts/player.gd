extends RigidBody2D


var max_health := 1000.0
var health := 1000.0 :
	set(value):
		var old_value = health
		if max_health != null:
			health = clamp(value, 0,max_health)
		else:
			health = value
		if old_value > health:
			take_damage()

var max_battery := 1000.0
var battery := 1000.0 :
	set(value):
		var old_value = battery
		if max_battery != null:
			battery = clamp(value, 0, max_battery)
		else:
			battery = value
		if old_value > battery:
			battery_discharged()

var move_battery_discharge_rate := 1.0;
var jump_battery_discharge_rate := 5.0;
var propeller_battery_discharge_rate := 10.0;

var roll_speed := 10000.0
var move_speed := 20000.0
var propelling_force := 25000.0
var propeller_fuel_max := 1000.0

var propeller_fuel := 1000.0 :
	set(value):
		#var old_value = propeller_fuel
		if propeller_fuel_max != null:
			propeller_fuel = clamp(value, 0,propeller_fuel_max)
		else:
			propeller_fuel = max(0, value)

var propeller_refill_amount := 100.0
var propeller_usage_amount := 1000.0 #per second
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
	
func _process(delta):
	move_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if abs(move_input) > 0:
		if !discharge_battery(move_battery_discharge_rate * delta):
			move_input = 0
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
		if discharge_battery(jump_battery_discharge_rate):
			jump_cooldown_timer.start()
			sound_manager.play_random_from_group("Hits")
			apply_impulse(Vector2.UP * jump_force)
	
	trail.modulate_color.a = clamp(remap(linear_velocity.length(), 0, 1000, 0, 1), 0, 1)
	
var prev_lin_vel_length := 0.0
func _physics_process(delta):
	apply_torque(move_input * roll_speed * delta)
	apply_force(Vector2(move_input * move_speed, 0.0) * delta)
	if is_propelling:
		if propeller_fuel - propeller_usage_amount * delta >= 0.0:
			propeller_fuel -= propeller_usage_amount * delta
			apply_force(Vector2.UP.rotated(propeller.global_rotation) * propelling_force * delta)
	elif propeller_fuel < propeller_fuel_max:	
		if discharge_battery(propeller_battery_discharge_rate * delta):
			propeller_fuel += propeller_refill_amount * delta
	
	var lin_vel = linear_velocity
	var lin_vel_length = lin_vel.length()
	if abs(lin_vel_length - prev_lin_vel_length) > 35.0:
		var collision_point = global_position + lin_vel.normalized() * -collision_shape_radius
		var effect_angle = (collision_point - global_position).angle() + PI
		disposable_effect_generator.spawn_effect("Smoke", collision_point, effect_angle)
	prev_lin_vel_length = lin_vel_length
	
	non_rotating_node.global_rotation = 0.0 
	
func take_damage():
	sound_manager.play_random_from_group("Hits")
	if health <= 0:	
		Global.camera.shake(1.0, 5.0)
		
		disposable_effect_generator.spawn_effect("Explosion", global_position)
		disposable_effect_generator.spawn_effect("Flashbang", global_position, randf() * TAU)
		sound_manager.play_random_from_group("Explosions")
		respawn_at(spawn_position)

func battery_discharged():
	#sound_manager.play_random_from_group("Hits")
	pass
func discharge_battery(amount):
	var successfull = false;
	if battery >= amount:
		successfull = true;
	battery -= amount;
	return successfull

func respawn_at(pos = Vector2.ZERO):
	is_dead = true
	await get_tree().create_timer(1.0).timeout
	health = max_health
	global_position = pos
	await get_tree().create_timer(1.0).timeout
	is_dead = false
