extends PlayerState

## Movement player state for Jumping state
## Can transition to Idle, Walking, Running and Sneaking

func enter() -> void:
	player.footsteps.playing = false

func physics_process(delta) -> void:
	# Set initial jump speed
	if player.is_on_floor():
		player.velocity.y = player.JUMP_SPEED
	player.velocity += delta * player.gravity * player.gravity_vector
	
	var horizontal_velocity = player.velocity
	horizontal_velocity.y = 0

	var target = player.direction
	target *= player.max_speed

	var accel
	if player.direction.dot(horizontal_velocity) > 0:
		accel = player.ACCEL
	else:
		accel = player.DEACCEL

	horizontal_velocity = horizontal_velocity.lerp(target, accel * delta)
	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z
	player.move_and_slide()
	
	# Landing.
	if player.is_on_floor():
		if is_equal_approx(horizontal_velocity.length_squared(), 0.0):
			exit('Idle')
		else:
			if Input.is_action_pressed('movement_run'):
				exit('Running')
			elif Input.is_action_pressed('movement_sneak'):
				exit('Sneaking')
			else:
				exit('Walking')
