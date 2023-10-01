extends Path2D

@export_multiline var warning := "add a child to this to make it move. child must not be effected by gravity or such. child must not queue_free itself"
@onready var path_follow := $PathFollow2D
@export var progression_speed := 0.3
@export var loop_back := true
@export var initial_progression := 0.0

var node
var going_forward_or_backwards := 1

@onready var sound_manager := $PathFollow2D/SoundManager
func _ready():
	set_process(false)
	set_physics_process(false)
	if get_child_count() > 1:
		node = get_children()[1]
		path_follow.progress_ratio = initial_progression
		set_process(true)
		set_physics_process(true)
		sound_manager.play_from_group("Ambient", "Ambient_1")
	else:
		print("no child found under path generator")

func _process(_delta):
	pass

func _physics_process(delta):
	node.global_position = path_follow.global_position
	sound_manager.global_position = path_follow.global_position
	path_follow.progress_ratio += progression_speed * delta * going_forward_or_backwards
	if path_follow.progress_ratio == 1 or path_follow.progress_ratio == 0 and loop_back:
		going_forward_or_backwards *= -1
