extends Node

@export var follow_source : Node2D
@export var force_follow_parent := false
@export var emitting := false : 
	set(value):
		emitting = value
		if emitting == false and disgarted_trails != null and is_node_ready():
			var old_trail = duplicate()
			old_trail.is_disgarted = true
			disgarted_trails.add_child(old_trail)
			line2D.points = []
@export var trail_length := 10
@export var trail_width := 10.0
@export var trail_width_curve : Curve
@onready var line2D = $Line2D
@export var trail_color : Gradient
@export var modulate_color := Color.WHITE:
	set(value):
		modulate_color = value
		if line2D != null:
			line2D.modulate = modulate_color
var is_disgarted := false

## good for creating long trails without filling the memory. but has less accuracy
@export var use_delay_timer_instead := false
@export var delay := 0.1
@onready var disgarted_trails := $DisgartedTrails

var point
func _ready():
	if is_disgarted:
		force_follow_parent = false
		follow_source = null
	else:
		if force_follow_parent:
			follow_source = get_parent()
		line2D.width = trail_width
		line2D.width_curve = trail_width_curve
		line2D.gradient = trail_color
		line2D.modulate = modulate_color
	
	
var delay_timer_t := 0.0
func _physics_process(delta):
	if !use_delay_timer_instead:
		create_point()
	else:
		if delay_timer_t > delay:
			delay_timer_t -= delay
			create_point()
		delay_timer_t += delta
		
func create_point():
	if emitting && is_instance_valid(follow_source):
		point = follow_source.global_position
		line2D.add_point(point)
		if line2D.points.size() > trail_length:
			line2D.remove_point(0)
	else:
		#line2D.points = []
		if line2D.points.size() > 0:
			line2D.remove_point(0)
	if is_disgarted and line2D.points.size() < 1:
		queue_free()
func on_delay_finish():
	create_point()
	
func get_absolute_z_index(target: Node2D) -> int:
	var node = target;
	var z_index = 0;
	while node and node.is_class('Node2D'):
		z_index += node.z_index;
		if !node.z_as_relative:
			break;
		node = node.get_parent();
	return z_index;
