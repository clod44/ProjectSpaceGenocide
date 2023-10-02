extends PathFollow2D

enum all_control_keys {
	UpDown,
	LeftRight
}
@export var control_keys := all_control_keys.UpDown
@export var move_speed := 100.0
@export var move_damping := 0.98
var move_input := 0.0
var velocity := 0.0

func _ready():
	pass # Replace with function body.


func _process(delta):
	if control_keys == all_control_keys.UpDown:
		move_input = Input.get_axis("move_up", "move_down")
	elif control_keys == all_control_keys.LeftRight:
		move_input = Input.get_axis("move_left", "move_right")
	
	velocity += move_input * move_speed
	progress += velocity * delta
	velocity *= move_damping
