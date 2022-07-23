class_name DebugOverlay extends VBoxContainer

@onready var performance_panel: PanelContainer = $PerformancePanel
@onready var player_panel: PanelContainer = $PlayerPanel
@onready var event_panel: PanelContainer = $EventPanel
var performance_action_name = 'ui_toggle_performance_overlay'
var player_action_name = 'ui_toggle_player_overlay'
var event_action_name = 'ui_toggle_event_overlay'

@onready var debug_theme = preload('res://assets/materials/themes/debug_theme.tres')
const OUTER_MARGIN = 30
const TEXT_MARGIN = 10
const ITEM_SEPARATION = 30
var width = 400
var height = ProjectSettings.get_setting('display/window/size/viewport_height') - (2 * OUTER_MARGIN)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set main container size and theme
	size = Vector2(width, height)
	theme = debug_theme
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_KEEP_SIZE, OUTER_MARGIN)
	add_theme_constant_override('separation', ITEM_SEPARATION)
	
	# Set layout of sub-panels
	init_layout(performance_panel)
	init_layout(player_panel)
	init_layout(event_panel)

func init_layout(panel) -> void:
	panel.visible = false
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.margin_container.add_theme_constant_override('margin_top', TEXT_MARGIN)
	panel.margin_container.add_theme_constant_override('margin_left', TEXT_MARGIN)
	panel.margin_container.add_theme_constant_override('margin_bottom', TEXT_MARGIN)
	panel.margin_container.add_theme_constant_override('margin_right', TEXT_MARGIN)
	panel.vbox_container.add_theme_constant_override('separation', TEXT_MARGIN)
	panel.title_label.fit_content_height = true
	panel.title_label.add_theme_font_size_override('font_size', 22)
	panel.text_label.fit_content_height = true

# Handle input action to toggle the visibiltiy of the overlay
func _input(event) -> void:
	if event.is_action_pressed(performance_action_name):
		toggle_visibility(performance_panel)
	if event.is_action_pressed(player_action_name):
		toggle_visibility(player_panel)
	if event.is_action_pressed(event_action_name):
		toggle_visibility(event_panel)

## Toggle the visibiltiy of the overlay
func toggle_visibility(panel) -> void:
	panel.visible = false if panel.visible else true
