extends Marker2D

@export var disabled = true
@onready var button := $Button
@onready var light := $Light
@onready var sprite := $Sprite2D
var tween
func _ready():
	tween = create_tween()
	tween.kill()
	button.connect("pressed", on_btn_press)
	button.connect("mouse_entered", on_mouse_entered)
	button.connect("mouse_exited", on_mouse_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_mouse_entered():
	light.enabled = true
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite, "scale", Vector2(1.1, 1.1), 1.0)
	tween.parallel().tween_property(button, "scale", Vector2(0.9, 0.9), 1.0)

func on_mouse_exited():
	light.enabled = false
	tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(sprite, "scale", Vector2.ONE, 1.0)
	tween.parallel().tween_property(button, "scale", Vector2.ONE, 1.0)
	

func on_btn_press():
	pass
