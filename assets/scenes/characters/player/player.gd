extends CharacterBody3D

#signal raycast_collider_changed(raycast_collider)

var gravity = ProjectSettings.get_setting('physics/3d/default_gravity')
var gravity_vector = ProjectSettings.get_setting('physics/3d/default_gravity_vector')

var direction = Vector3()
var max_speed
var looking_at: Object:
	get: return looking_at
	set(value):
		looking_at = value
		SignalBus.emit_signal('player_looking_at_changed', looking_at)

const WALK_SPEED = 4
const RUN_SPEED = 6
const SNEAK_SPEED = 2
const JUMP_SPEED = 4
const ACCEL = 6
const DEACCEL= 16
const MOUSE_SENSITIVITY = 0.05

#@onready var skeleton: Skeleton3D = $FemaleCharacter/Armature/Skeleton3D
#@onready var neck_bone_idx = skeleton.find_bone('neck_01')
@onready var collision_shape_body = $BodyCollisionShape
@onready var rotation_helper = $RotationHelper
@onready var camera = $RotationHelper/Camera
@onready var raycast = $RotationHelper/Camera/RayCast3D
@onready var footsteps = $Audio/Footsteps
@onready var movement_state_machine = $MovementStateMachine
@onready var animation_player = $AnimationPlayer


func _ready():
	add_to_group('player')
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	movement_state_machine.init_state()
	SignalBus.emit_signal('player_initialized', self)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = deg2rad(clamp(rad2deg(camera_rot.x), -70, 70))
		rotation_helper.rotation = camera_rot
		
func _physics_process(_delta):
	process_rasycast()

## Process the player raycast to determine if player is looking at an interactive object
func process_rasycast() -> void:
	# Raycasting
	if raycast.is_colliding():
		# Get collision object
		var obj = raycast.get_collider()
		# Set looking_at reference if object is interactive and has changed
		if obj is Interactive:
			if obj != looking_at:
				looking_at = obj
				looking_at.targeted = true
				#print('Now looking at {looking_at}'.format({'looking_at': looking_at}))
		# Remove previous looking_at target if collision with non-interactive target
		else:
			if looking_at != null and looking_at is Interactive:
				looking_at.targeted = false
				looking_at = null
	else:
		# Remove previous looking_at target if no collision
		if looking_at != null and looking_at is Interactive:
			#print('No longer looking at {looking_at}'.format({'looking_at': looking_at}))
			looking_at.targeted = false
			looking_at = null
