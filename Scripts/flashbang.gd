extends PointLight2D


@export var emitting := false :
	set(value):
		emitting = value
		if emitting and duration != null and tween != null:
			enabled = true
			tween.kill()
			tween = create_tween()
			tween.tween_property(self, "energy", 0.0, duration)
			tween.tween_callback(func():
				emitting = false
				)
			
@export var duration = 1.0
var tween 
func _ready():
	tween = create_tween()
	tween.kill()
	emitting = emitting
