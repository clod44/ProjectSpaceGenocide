extends Marker2D

## this node is basically the desired pose of the physical platform irigdbody2d
@export var lock_rotation := true
@onready var platform := $Node/PlatformPhysical
@export var desired_force := 100000.0

func _ready():
	$Placeholder.queue_free()
	platform.lock_rotation = lock_rotation
	platform.global_position = global_position


func _process(_delta):
	pass


func _physics_process(delta):
	var force = global_position - platform.global_position
	platform.apply_force(force * delta * desired_force)
