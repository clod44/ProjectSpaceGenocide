extends RigidBody2D

var health := 100000.0 :
	set(value):
		var old_value = health
		health = value
		if old_value != health:
			take_damage()
var roll_speed := 20000.0
var move_speed := 10000.0
var propelling_force := 20000.0
var propeller_fuel_max := 2.0
var propeller_fuel := 2.0
var propeller_per_sec := 0.5
var jump_force := 100.0
@onready var jump_cooldown_timer := $JumpCooldown
var jump_cooldown := 0.5

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
func _ready():
	Global.player = self
	collision_shape_radius = $CollisionShape2D.shape.radius
	
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
	if jump_cooldown_timer.is_stopped() and Input.is_action_just_pressed("jump"):
		jump_cooldown_timer.start()
		apply_impulse(Vector2.UP * jump_force)
	
	trail.modulate_color.a = clamp(remap(linear_velocity.length(), 0, 1000, 0, 1), 0, 1)
	
var prev_lin_vel_length := 0.0
func _physics_process(delta):
	apply_torque(move_input * roll_speed * delta)
	apply_force(Vector2(move_input * move_speed, 0.0) * delta)
	if is_propelling and propeller_fuel -2.0 * delta >= 0.0:
		propeller_fuel -= 2.0 * delta
		apply_force(Vector2.UP.rotated(propeller.global_rotation) * propelling_force * delta)
	propeller_fuel = min(propeller_fuel + propeller_per_sec * delta, propeller_fuel_max)
	
	var lin_vel = linear_velocity
	var lin_vel_length = lin_vel.length()
	if abs(lin_vel_length - prev_lin_vel_length) > 35.0:
		var collision_point = global_position + lin_vel.normalized() * -collision_shape_radius
		var effect_angle = (collision_point - global_position).angle() + PI
		disposable_effect_generator.spawn_effect("smoke", collision_point, effect_angle)
	prev_lin_vel_length = lin_vel_length

func take_damage():
	print("ouch!")
	if health <= 0:
		queue_free()

