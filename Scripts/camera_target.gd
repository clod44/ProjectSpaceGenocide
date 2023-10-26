extends PathFollow2D

enum all_control_keys {
	ScrollUpDown,
	UpDown,
	LeftRight
}
@export var control_keys := all_control_keys.ScrollUpDown
@export var move_speed := 100.0
@export var move_damping := 0.9
var move_input := 0.0
var velocity := 0.0

func _ready():
	pass # Replace with function body.


func _process(delta):
	if  control_keys == all_control_keys.ScrollUpDown:
		if Input.is_action_just_released("scroll_down"):
			move_input = 1
		elif Input.is_action_just_released("scroll_up"):
			move_input = -1
	elif control_keys == all_control_keys.UpDown:
		move_input = Input.get_axis("move_up", "move_down")
	elif control_keys == all_control_keys.LeftRight:
		move_input = Input.get_axis("move_left", "move_right")
	
	velocity += move_input * move_speed
	progress += velocity * delta
	velocity *= move_damping
	move_input = 0
	
	if progress_ratio == 0.0 or progress_ratio == 1.0:
		velocity = 0
