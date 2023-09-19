extends Marker2D

@export_multiline var warning := "put your cpu/gpu effect as a child to this node. if they have direction, make them move towards right. effect will queue_free when it stops emitting. add effect names to the effect_library. leave the value section null"
@export var effect_library = {
	"default_name" : null
}
@onready var active_effects := $ActiveEffects
func _ready():
	var effects = get_children()
	var i = 1
	for effect_name in effect_library.keys():
		effect_library[effect_name] = effects[i].duplicate()
	#clear the physical effects now
	for j in range(effects.size()):
		if j == 0:
			continue
		effects[j].queue_free()
	
	
func _process(delta):
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
