extends RigidBody2D

@export var health := 1000.0 :
	set(value):
		var old_value = health
		health = max(0,value)
		if old_value > health:
			take_damage(old_value - health)
var is_dead : bool = false;
@export var can_queue_free : bool = true
var disposable_effect_generator = null
var sound_manager = null

func _ready():
	disposable_effect_generator = get_node_or_null("DisposableEffectGenerator")
	sound_manager = get_node_or_null("SoundManager")
	
func take_damage(amount):
	if is_dead:
		return;
	
	if is_instance_valid(sound_manager):
		sound_manager.play_random_from_group("Hits")
	if health <= 0:
		die()
		return
	
func die():
	if is_dead:
		return;
	
	if is_instance_valid(disposable_effect_generator):
		disposable_effect_generator.spawn_effect("Explosion", global_position, 0)
	sound_manager.play_random_from_group("Explosions")
	if can_queue_free:
		queue_free()
