extends Path2D

@export_multiline var warning := "add a child to this to make it move. child must not be effected by gravity or such"
@onready var path_follow := $PathFollow2D
@export var progression_speed := 0.3
@export var loop_back := true

var node
var going_forward_or_backwards := 1

func _ready():
	node = get_children()[1]


func _process(_delta):
	pass

func _physics_process(delta):
	node.global_position = path_follow.global_position
	path_follow.progress_ratio += progression_speed * delta * going_forward_or_backwards
	if path_follow.progress_ratio == 1 or path_follow.progress_ratio == 0 and loop_back:
		going_forward_or_backwards *= -1
