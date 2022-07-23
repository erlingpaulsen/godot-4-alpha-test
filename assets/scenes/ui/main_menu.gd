extends PanelContainer

## Reference to the outer margin container, which will hold each sub-menu
@onready var outer_margin_container: MarginContainer = $OuterMarginContainer
## Array of all sub-menu containers
@onready var menu_containers: Array = outer_margin_container.get_children()
## Load external menu theme
@onready var menu_theme = preload('res://assets/materials/themes/menu_theme.tres')

var width = ProjectSettings.get_setting('display/window/size/viewport_width')
var height = ProjectSettings.get_setting('display/window/size/viewport_height')

const OUTER_MARGIN_VERTICAL = 300
const OUTER_MARGIN_HORIZONTAL = 600
const ITEM_SEPARATION = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set main container visibility, size, theme and process mode
	visible = false
	size = Vector2(width, height)
	theme = menu_theme
	# Always process, even if scene is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set the outer margins for the MarginContainer which will contain each sub-menu
	outer_margin_container.add_theme_constant_override('margin_top', OUTER_MARGIN_VERTICAL)
	outer_margin_container.add_theme_constant_override('margin_left', OUTER_MARGIN_HORIZONTAL)
	outer_margin_container.add_theme_constant_override('margin_bottom', OUTER_MARGIN_VERTICAL)
	outer_margin_container.add_theme_constant_override('margin_right', OUTER_MARGIN_HORIZONTAL)
	
	# Formatting all box containers
	for box_container in find_children('', 'BoxContainer', true):
		box_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		box_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		box_container.add_theme_constant_override('separation', ITEM_SEPARATION)
		
		# Set all sub-menu box container visibility to false
		if 'Menu' in box_container.name:
			box_container.visible = false
	
	# Formatting all buttons and connecting to signals
	for button in find_children('', 'Button', true):
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		#button.add_theme_stylebox_override('normal', stylebox)
		if button.name == 'ResumeButton':
			button.pressed.connect(_on_ResumeButton_pressed)
		elif button.name == 'ControlsButton':
			button.pressed.connect(_on_ControlsButton_pressed)
		elif button.name == 'SettingsButton':
			button.pressed.connect(_on_SettingsButton_pressed)
		elif button.name == 'ExitButton':
			button.pressed.connect(_on_ExitButton_pressed)
		elif button.name == 'BackButton':
			button.pressed.connect(_on_BackButton_pressed)
	
	# Formatting all labels
	for label in find_children('', 'Label', true):
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

# Handle input action to toggle the visibiltiy of the overlay
func _input(event) -> void:
	if event.is_action_pressed('ui_cancel'):
		toggle_pause()

## Toggle the visibiltiy of the overlay
func toggle_visibility(panel) -> void:
	panel.visible = false if panel.visible else true

## Toggle game pause
func toggle_pause() -> void:
	# Capturing/Freeing the cursor
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	# Pausing/unpausing scene tree
	get_tree().paused = false if get_tree().paused else true
	
	# Toggle menu visibility
	toggle_visibility(self)
	for menu_container in menu_containers:
		if menu_container.name == 'MainMenu':
			toggle_visibility(menu_container)

## Toggle pause on button pressed
func _on_ResumeButton_pressed() -> void:
	toggle_pause()

## Open Controls menu on button pressed
func _on_ControlsButton_pressed() -> void:
	for menu_container in menu_containers:
		if menu_container.name == 'MainMenu':
			toggle_visibility(menu_container)
		if menu_container.name == 'ControlsMenu':
			toggle_visibility(menu_container)

## Open Settings menu on button pressed
func _on_SettingsButton_pressed() -> void:
	pass

## Exit game on button pressed
func _on_ExitButton_pressed() -> void:
	get_tree().quit()

## Return to main menu on button pressed
func _on_BackButton_pressed() -> void:
	for menu_container in menu_containers:
		if menu_container.visible:
			menu_container.visible = false
		if menu_container.name == 'MainMenu':
			toggle_visibility(menu_container)
