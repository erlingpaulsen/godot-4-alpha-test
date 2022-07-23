extends StaticBody3D

@export var mesh_LOD1: MeshInstance3D
@export var mesh_LOD2: MeshInstance3D
@onready var seed = randf()

func _ready():
	mesh_LOD1.set_shader_instance_uniform('seed', seed)
	mesh_LOD2.set_shader_instance_uniform('seed', seed)
