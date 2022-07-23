extends State

## Special type of state which also contains a typed reference to the CharacterBody3D player node
## Movement state machine states will inherit PlayerState

class_name PlayerState

# Typed reference to the player node.
var player: CharacterBody3D

func _ready() -> void:
	# The states are children of the `Player` node so their `_ready()` callback will execute first.
	# That's why we wait for the `owner` to be ready first.
	await owner
	# The `as` keyword casts the `owner` variable to the `Player` type.
	# If the `owner` is not a `Player`, we'll get `null`.
	player = owner as CharacterBody3D
	# This check will tell us if we inadvertently assign a derived state script
	# in a scene other than `Player.tscn`, which would be unintended. This can
	# help prevent some bugs that are difficult to understand.
	assert(player != null)
