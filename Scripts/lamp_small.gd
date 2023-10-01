extends PointLight2D


@export var light_on_chance = 0.1
@export var light_off_chance = 0.01
var default_energy := 1.0
## custom_state_on needs to be reassigned to make this take effect properly
@export var force_state := false
## needs to be reassigned to take effect after updating force_state to true
@export var custom_state_on := true :
	set(value):
		custom_state_on = value
		energy = default_energy if custom_state_on else 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	default_energy = energy
	custom_state_on = custom_state_on


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !force_state:
		if randf() < light_on_chance:
			energy = default_energy
		elif randf() < light_off_chance:
			energy = 0.0
		
