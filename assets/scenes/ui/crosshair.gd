class_name Crosshair extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	# Always process, even if scene is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

# Handle input action to toggle the visibiltiy of the overlay
func _input(event) -> void:
	if event.is_action_pressed('ui_cancel'):
		toggle_visibility()

## Toggle crosshair visibility
func toggle_visibility() -> void:
	visible = false if visible else true
