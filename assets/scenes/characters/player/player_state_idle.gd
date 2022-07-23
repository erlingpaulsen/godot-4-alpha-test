class_name PlayerStateIdle extends PlayerState

## Movement player state for Idle state
## Can transition to Walking, Running, Jumping and Sneaking

func enter():
	player.max_speed = player.WALK_SPEED
	player.velocity = Vector3.ZERO
	player.footsteps.playing = false

func physics_process(_delta):
	if Input.is_action_pressed("movement_forward") or Input.is_action_pressed("movement_backward") or Input.is_action_pressed("movement_left") or Input.is_action_pressed("movement_right"):
		if Input.is_action_pressed("movement_run"):
			exit('Running')
		else:
			exit('Walking')
	elif Input.is_action_pressed("movement_jump"):
		exit('Jumping')
	elif Input.is_action_pressed("movement_sneak"):
		exit('Sneaking')
		
	if not player.is_on_floor():
		exit('Jumping')
