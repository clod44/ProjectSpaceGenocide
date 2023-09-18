extends RigidBody2D

var health := 100000.0 :
	set(value):
		var old_value = health
		health = value
		if old_value != health:
			take_damage()
var roll_speed := 10000.0
var propelling_force := 10000.0
var propeller_fuel_max := 2.0
var propeller_fuel := 2.0
var propeller_per_sec := 0.5
var jump_force := 50.0
@onready var jump_cooldown_timer := $JumpCooldown
var jump_cooldown := 1.0

@onready var propeller := $Propeller
@onready var propeller_flame := $Propeller/PropellerFlame
var is_propelling := false :
	set(value):
		var old_value = is_propelling
		is_propelling = value
		if is_propelling != old_value:
			propeller_flame.emitting = is_propelling

var roll_input := 0.0
func _ready():
	Global.player = self

func _process(_delta):
	roll_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
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
		apply_impulse(Vector2.UP * jump_force)
	
func _physics_process(delta):
	apply_torque(roll_input * roll_speed * delta)
	if is_propelling and propeller_fuel -2.0 * delta >= 0.0:
		propeller_fuel -= 2.0 * delta
		apply_force(Vector2.UP.rotated(propeller.global_rotation) * propelling_force * delta)
	propeller_fuel = min(propeller_fuel + propeller_per_sec * delta, propeller_fuel_max)
	
func take_damage():
	print("ouch!")
	if health <= 0:
		queue_free()
