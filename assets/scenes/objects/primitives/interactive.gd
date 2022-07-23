class_name Interactive extends StaticBody3D

## Interactive class for static objects which can be interacted with by the player (consumable, equippable, pickable etc.)

## Enum for defining interactive sub-types
enum {INTERACTIVE_LOOTABLE, INTERACTIVE_CONSUMABLE, INTERACTIVE_EQUIPPABLE}

## Shader material for interaction - will be overlayed on object meshes if object is looked at by player
@onready var interact_shader_material: ShaderMaterial = preload('res://assets/materials/effects/item_interact.tres')
## List of child mesh instances of any node that inherits Interactive
@onready var mesh_instances: Array = find_children('', 'MeshInstance3D', true)

## If objected is targeted (looked at) by the player or not
var targeted: bool:
	get: return targeted
	set(value):
		# Set targeted value and toggle the interact shader on all child meshes
		targeted = value
		for mesh_instance in mesh_instances:
			if value:
				# Activate interact shader
				mesh_instance.material_overlay = interact_shader_material
			else:
				# Deactivate interact shader
				mesh_instance.material_overlay = null

# Called when the node enters the scene tree for the first time.
func _ready():
	targeted = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
