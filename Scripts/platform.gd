extends Marker2D

## this node is basically the desired pose of the physical platform irigdbody2d
@export var lock_rotation := true
@onready var platform := $Node/PlatformPhysical
@export var desired_force := 100000.0
@export var initial_angle := 0.0
@export var rotate := true
@export var rotation_torque := 1000000.0

func _ready():
	$Placeholder.queue_free()
	platform.lock_rotation = lock_rotation
	platform.global_position = global_position
	platform.global_rotation = initial_angle


func _process(_delta):
	pass


func _physics_process(delta):
	var force = global_position - platform.global_position
	platform.apply_force(force * delta * desired_force)
	if rotate:
		platform.apply_torque(rotation_torque * delta)
