extends Node

class_name StateMachine

const DEBUG = false

var state: State
var history = []

func _ready() -> void:
	add_to_group('state_machines')

## Sets the initial state of the state machine to the first child node and calls _enter_state
func init_state() -> void:
	state = get_child(0)
	_enter_state()

## Transitions to new state after appending current state to history
## Set new state as current state and call _enter_state
func transition_to(new_state) -> void:
	history.append(state.name)
	state = get_node(new_state)
	_enter_state()

func back() -> void:
	if history.size() > 0:
		state = get_node(history.pop_back())
		_enter_state()

## Provides the state with a reference to the state machine and calls the enter method of the state
func _enter_state() -> void:
	if DEBUG:
		print("Entering state: ", state.name)
	SignalBus.emit_signal('player_movement_state_changed', state, history)
	# Give the new state a reference to this state machine script
	state.state_machine = self
	state.enter()

# Route Game Loop function calls to
# current state handler method if it exists
func _process(delta) -> void:
	if state.has_method("process"):
		state.process(delta)

func _physics_process(delta) -> void:
	if state.has_method("physics_process"):
		state.physics_process(delta)

func _input(event) -> void:
	if state.has_method("input"):
		state.input(event)

func _unhandled_input(event) -> void:
	if state.has_method("unhandled_input"):
		state.unhandled_input(event)

func _unhandled_key_input(event) -> void:
	if state.has_method("unhandled_key_input"):
		state.unhandled_key_input(event)

#func _notification(what) -> void:
#	if state && state.has_method("notification"):
#		state.notification(what)
