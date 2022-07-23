class_name PlayerStateSneaking extends PlayerState

## Movement player state for Running state
## Can transition to Idle, Walking and Jumping

func enter() -> void:
	player.max_speed = player.SNEAK_SPEED
	player.animation_player.play('sneak_start')
	#player.footsteps.playing = true

func exit(next_state):
	player.animation_player.play('sneak_stop')
	state_machine.transition_to(next_state)
	return next_state

func physics_process(delta) -> void:
	player.direction = Vector3()
	var cam_xform = player.camera.get_global_transform()

	var input_movement_vector = Vector2()

	if Input.is_action_pressed('movement_forward'):
		input_movement_vector.y += 1
	if Input.is_action_pressed('movement_backward'):
		input_movement_vector.y -= 1
	if Input.is_action_pressed('movement_left'):
		input_movement_vector.x -= 1
	if Input.is_action_pressed('movement_right'):
		input_movement_vector.x += 1
	if Input.is_action_just_released('movement_sneak'):
		if is_equal_approx(player.velocity.length_squared(), 0.0):
			exit('Idle')
		else:
			exit('Walking')
	if Input.is_action_just_pressed("movement_jump"):
		exit('Jumping')

	input_movement_vector = input_movement_vector.normalized()

	# Basis vectors are already normalized.
	player.direction += -cam_xform.basis.z * input_movement_vector.y
	player.direction += cam_xform.basis.x * input_movement_vector.x
	
	player.direction.y = 0
	player.direction = player.direction.normalized()

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
