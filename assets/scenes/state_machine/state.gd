extends Node
class_name State

var state_machine: StateMachine

func enter() -> void:
	#exit("State2")
	pass

func exit(next_state):
	state_machine.transition_to(next_state)
	return next_state

# Optional handler functions for game loop events
func process(delta):
	# Add handler code here
	return delta

func physics_process(delta):
	return delta

func input(event):
	return event

func unhandled_input(event):
	return event

func unhandled_key_input(event):
	return event

func notification(what, flag = false):
	return [what, flag]
