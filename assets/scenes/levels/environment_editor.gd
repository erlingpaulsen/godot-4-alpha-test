extends WorldEnvironment


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Handle input action to toggle the visibiltiy of the overlay
func _input(event) -> void:
	if event.is_action_pressed('env_toggle_sdfgi'):
		environment.sdfgi_enabled = false if environment.sdfgi_enabled else true
