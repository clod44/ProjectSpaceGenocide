extends Camera2D


@export_multiline var warning := "make sure to place this at top most of the scene as possible"
@export_subgroup("Camera")
## node that the camera will follow by setting the target_pos the node's global_position
@export var follow_node : Node2D
## if follow_node exists, this will be overwritten
@export var target_pos : Vector2
## camera smooth follow interpolation value 
## [br]0.1 = smooth camera follow
## [br]1.0 = instant camera snap 
@export var smoothing_speed := 0.3
@export var follow_ahead := false
@export var follow_ahead_factor := 0.1
@export var follow_ahead_max_dist := 100

@export var mouse_offset_factor := 0.01
var desired_zoom := 1.0
var current_zoom := 1.0

@export_group("Zooming")
## zoom speed/smoothness
@export var zoom_interpolation := 0.1
@export_subgroup("Zooming")
@export var max_zoom_out := 4.0
@export var max_zoom_in := 5.0

@export_subgroup("Camera Shake")
var shake_amount := 1.0 #this represent the t of shaking 1 to 0 expoential decay. dont touch this
var shake_strength := 5.0
var default_offset = offset
@onready var tween = create_tween()
@onready var timer = $Timer
var shaking = false


var dangle_vel = Vector2.ZERO
var dangle_pos = Vector2.ONE
var dangle_speed = 100.0
var dangle_damping = 0.01
var dangle_factor = 0.1

@onready var red_screen := $RedScreen
func _ready():
	#see https://www.youtube.com/watch?v=4mll7LKIITM for camera shaking stuff and global accessing
	Global.camera = self
	randomize() #randomize RNG seed

	# have to stop it manually after creation otherwise Godot complains
	tween.kill()
	
	#init
	if follow_node:
		target_pos = follow_node.global_position
	else:
		target_pos = Vector2.ZERO
	global_position = target_pos
	
	timer.connect("timeout", _on_timer_timeout)
	Global.connect("player_updated", on_player_update)

func on_player_update():
	follow_node = Global.player

func _physics_process(delta):
	if is_instance_valid(follow_node):
		target_pos = follow_node.global_position
		if follow_ahead:
			var follow_ahead_offset = follow_node.velocity * follow_ahead_factor
			target_pos += follow_ahead_offset.limit_length(follow_ahead_max_dist)
		if "health" in follow_node and "max_health" in follow_node:
			red_screen.energy = lerp(
				red_screen.energy,
				remap(follow_node.health, 0.0, follow_node.max_health, 1.0, 0.0),
				0.1)
			dangle_factor =  (1.0 - follow_node.health / follow_node.max_health) *0.1
		else:
			red_screen.energy = lerp(red_screen.energy, 0.0, 0.01)
			dangle_factor = 0.0
	else:
		red_screen.energy = lerp(red_screen.energy, 0.0, 0.01)
		dangle_factor = 0.0
	
	var smoothed_pos = global_position.lerp(target_pos, smoothing_speed * delta * 60)
	global_position = smoothed_pos + get_local_mouse_position() * mouse_offset_factor 
	
	if(Input.is_action_just_released("zoom_in")):
		desired_zoom -= 1
	elif(Input.is_action_just_released("zoom_out")):
		desired_zoom += 1
	
	desired_zoom = clamp(desired_zoom, max_zoom_out, max_zoom_in)
	current_zoom = lerp(current_zoom, desired_zoom, zoom_interpolation * delta * 60)
	zoom = Vector2(current_zoom, current_zoom)
	
	var shake_offset = Vector2.ZERO
	if shaking:
		shake_offset = Vector2(
			randf_range(-1, 1), 
			randf_range(-1, 1)
			).normalized() * shake_strength * shake_amount
		shake_amount *= max(timer.time_left / timer.wait_time, 0)
	
	dangle_vel = Vector2(
			randf_range(-1, 1), 
			randf_range(-1, 1)
			).normalized()
	dangle_pos += dangle_vel * dangle_speed * delta
	dangle_pos = lerp(dangle_pos, Vector2.ZERO, dangle_damping)
		
	#shaking
	offset +=shake_offset
	#dangling	
	offset = lerp(offset, offset + dangle_pos, dangle_factor)
	#return back force
	offset = lerp(offset, Vector2.ZERO, 0.1)

func shake(time, _shake_strength):
	timer.wait_time = time
	shake_amount = 1 #reset linear decay
	shake_strength = _shake_strength
	shaking = true
	timer.start()


func _on_timer_timeout():
	shaking = false
