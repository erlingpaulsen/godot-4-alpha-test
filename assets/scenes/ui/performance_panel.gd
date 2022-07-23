extends PanelContainer

## Performance overlay extending PanelContainer, used to display performance metrics
## Script should be attached to PanelContainer node as a child of GenericOverlay
## Used with MarginContainer -> RichTextLabel as child tree

## How often the performance details should be refreshed in seconds
var refresh_rate = 0.2
## Timer variable
var time = 0

var margin_container = MarginContainer.new()
var vbox_container = VBoxContainer.new()
var title_label = RichTextLabel.new()
var text_label = RichTextLabel.new()

## Used to convert bytes to MB
const BYTES_PER_MB = 1048576

# Variables to hold performance metrics
var fps: String
var process_time: String
var phys_process_time: String
var object_count: String
var resource_count: String
var render_objects: String
var render_primitives: String
var draw_calls: String
var video_mem_used: String
var tex_mem_used: String
var buff_mem_used: String

func _ready() -> void:
	add_child(margin_container)
	margin_container.add_child(vbox_container)
	vbox_container.add_child(title_label)
	vbox_container.add_child(text_label)
	title_label.text = 'Performance Panel'

func _process(delta) -> void:
	# If text box is visible, update and display metrics at a given refresh rate
	if visible:
		time += delta
		if time > refresh_rate:
			update_variables()
			update_text_label()
			time = 0

## Updates the performance metrics	
func update_variables() -> void:
	fps = String.num(Performance.get_monitor(Performance.TIME_FPS))
	process_time = String.num(Performance.get_monitor(Performance.TIME_PROCESS), 5)
	phys_process_time = String.num(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS), 5)
	object_count = String.num(Performance.get_monitor(Performance.OBJECT_COUNT))
	resource_count = String.num(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	render_objects = String.num(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME))
	render_primitives = String.num(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
	draw_calls = String.num(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	video_mem_used = String.num(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / BYTES_PER_MB, 1)
	tex_mem_used = String.num(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / BYTES_PER_MB, 1)
	buff_mem_used = String.num(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / BYTES_PER_MB, 1)

## Updates the RichTextLabel text
func update_text_label():
	var text = '''{fps} FPS
{process_time} seconds per frame
{phys_process_time} seconds per physics frame
{object_count} objects instanced
{resource_count} resources used
{render_objects} objects drawn per frame
{render_primitives} primitives drawn per frame
{draw_calls} draw calls per frame
{video_mem_used} video memory used
{tex_mem_used} texture memory used
{buff_mem_used} buffer memory used'''
	
	text_label.text = text.format({
		'fps': fps,
		'process_time': process_time,
		'phys_process_time': phys_process_time, 
		'object_count': object_count, 
		'resource_count': resource_count, 
		'render_objects': render_objects,
		'render_primitives': render_primitives,
		'draw_calls': draw_calls,
		'video_mem_used': video_mem_used,
		'tex_mem_used': tex_mem_used,
		'buff_mem_used': buff_mem_used
	})
