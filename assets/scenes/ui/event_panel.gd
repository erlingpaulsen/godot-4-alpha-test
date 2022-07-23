extends PanelContainer

## Event overlay extending PanelContainer, used to display the most recent input events
## Script should be attached to PanelContainer node as a child of GenericOverlay
## Used with MarginContainer -> RichTextLabel as child tree

## How many of the most recent events to be displayed
@export var event_count = 8

## Array to hold the event history
var event_history = []

var margin_container = MarginContainer.new()
var vbox_container = VBoxContainer.new()
var title_label = RichTextLabel.new()
var text_label = RichTextLabel.new()

func _ready() -> void:
	add_child(margin_container)
	margin_container.add_child(vbox_container)
	vbox_container.add_child(title_label)
	vbox_container.add_child(text_label)
	title_label.text = 'Input Event Panel'

func _input(event) -> void:
	# If event is pressed, is and action and it not an echo
	if event.is_pressed() and event.is_action_type() and not event.is_echo():
		# Append event to event history
		update_event_history(event)
		# Display event history
		update_text_label()

## Updates the event history array, latest event is appended at the end
func update_event_history(event) -> void:
	if event_history.size() == event_count:
		event_history.pop_front()
	event_history.append(event.as_text())

## Updates the text of the RichTextLabel
func update_text_label() -> void:
	var text = ''
	var i = 0
	for e in event_history:
		text += e
		if i < (event_history.size() - 1):
			text += '\n'
		i += 1
	text_label.text = text
