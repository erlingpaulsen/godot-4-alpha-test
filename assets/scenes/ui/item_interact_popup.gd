extends Control

@onready var panel_container_key: PanelContainer = $PanelContainerKey
@onready var panel_container_value: PanelContainer = $PanelContainerValue
@onready var label_key: Label = $PanelContainerKey/LabelKey
@onready var label_value: Label = $PanelContainerValue/LabelValue

@onready var panels = [panel_container_key, panel_container_value]
@onready var labels = [label_key, label_value]

@onready var menu_theme = preload('res://assets/materials/themes/menu_theme.tres')

@onready var input_events: Array[InputEvent] = InputMap.action_get_events('object_interact')

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	theme = menu_theme
	SignalBus.player_looking_at_changed.connect(_on_Player_looking_at_changed)
	for label in labels:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override('font_size', 36)
	
	if input_events.size() > 0:
		label_key.text = OS.get_keycode_string(input_events[0].physical_keycode)

	label_value.text = 'Use'


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_Player_looking_at_changed(obj) -> void:
	if obj != null:
		visible = true
	else:
		visible = false
