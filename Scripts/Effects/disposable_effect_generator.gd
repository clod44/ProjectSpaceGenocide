extends Marker2D

@export_multiline var warning := "put your cpu/gpu effect as a child to this node"
var effect_library = {}
@onready var active_effects := $ActiveEffects
func _ready():
	for effect in get_children():
		effect_library[effect.name] = effect.duplicate()
	#clear the physical effects now
	for j in range(get_child_count()):
		if j == 0:
			continue
		get_children()[j].queue_free()
	
	
func _process(_delta):
	for active_effect in active_effects.get_children():
		if active_effect.emitting == false:
			active_effect.queue_free()

func spawn_effect(effect_name, global_pos, global_rot = 0.0):
	if effect_name in effect_library.keys():
		var new_effect = effect_library[effect_name].duplicate()
		new_effect.global_position = global_pos
		new_effect.global_rotation = global_rot
		new_effect.emitting = true
		active_effects.add_child(new_effect)
	else:
		print("effect name not found")
