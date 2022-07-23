extends PanelContainer

## State overlay extending PanelContainer, used to display the current and previous states of a state machine
## Script should be attached to PanelContainer node as a child of GenericOverlay
## Used with MarginContainer -> RichTextLabel as child tree

## Reference to RichTextLabel, which will hold the text to display in the overlay
var margin_container = MarginContainer.new()
var vbox_container = VBoxContainer.new()
var title_label = RichTextLabel.new()
var text_label = RichTextLabel.new()

## State machine previous state
var prev_state: String

## State machine current
var curr_state: String

## Array of state machines in scene
var state_machines: Array[StateMachine]

## Reference to player CharacterBody3D
var player: CharacterBody3D

## How often the performance details should be refreshed in seconds
var refresh_rate = 0.1
## Timer variable
var time = 0

func _ready() -> void:
	add_child(margin_container)
	margin_container.add_child(vbox_container)
	vbox_container.add_child(title_label)
	vbox_container.add_child(text_label)
	title_label.text = 'Player Panel'
	
	# Fetch player node
	player = get_tree().get_nodes_in_group('player')[0]
	
	# Fetch all nodes added to group 'state_machines' and connect to the state_changed signal
	#state_machines = get_tree().get_nodes_in_group('state_machines')
	#for state_machine in state_machines:
	SignalBus.player_movement_state_changed.connect(_on_Player_Movement_StateMachine_state_changed)
		
	update_text_label()

func _on_Player_Movement_StateMachine_state_changed(state, history) -> void:
	curr_state = state.name
	if history.size() > 0:
		prev_state = history[-1]
	if visible:
		update_text_label()

func _process(delta) -> void:
	# If text box is visible, update and display metrics at a given refresh rate
	if visible:
		time += delta
		if time > refresh_rate:
			update_text_label()
			time = 0

func update_text_label():
	if player != null and state_machines != null:
		var text = 'Position: ({pos_x}, {pos_y}, {pos_z})\nRotation: ({rot_x}, {rot_y}, {rot_z})\nVelocity: ({vel_x}, {vel_y}, {vel_z})\n\nCurrent state: {curr_state}\nPrevious state: {prev_state}\n\nLooking at: {looking_at}'
		text_label.text = text.format({
			'curr_state': curr_state, 
			'prev_state': prev_state, 
			'pos_x': String.num(player.position.x, 2), 
			'pos_y': String.num(player.position.y, 2), 
			'pos_z': String.num(player.position.z, 2),
			'rot_x': String.num(rad2deg(player.rotation.x), 1), 
			'rot_y': String.num(rad2deg(player.rotation.y), 1), 
			'rot_z': String.num(rad2deg(player.rotation.z), 1),
			'vel_x': String.num(player.velocity.x, 2),
			'vel_y': String.num(player.velocity.y, 2),
			'vel_z': String.num(player.velocity.z, 2),
			'looking_at': player.looking_at
		})
	else:
		text_label.text = 'Player or state machine not found\nPlayer: {player}\nState machines: {state_machines}'.format({'player': player, 'state_machines': state_machines})
