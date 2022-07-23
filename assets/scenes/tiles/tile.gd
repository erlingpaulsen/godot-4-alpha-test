@tool
extends StaticBody3D

var collision_shape
var tile_meshes

@export var shader_material: ShaderMaterial:
	get: return shader_material
	set(value):
		shader_material = value
		if tile_meshes:
			update_shader_material()
			
@export var tile_size = 4:
	get: return tile_size
	set(value):
		tile_size = value
		if has_node('TileMeshes') and has_node('CollisionShape3D'):
			update_tile_size()
			set_shader_param('tile_size', tile_size)
			
@export var subdivide_count_LOD1 = 256:
	get: return subdivide_count_LOD1
	set(value):
		subdivide_count_LOD1 = value
		if has_node('TileMeshes/Mesh_LOD1'):
			get_node('TileMeshes/Mesh_LOD1').mesh.subdivide_width = value
			get_node('TileMeshes/Mesh_LOD1').mesh.subdivide_depth = value
			
@export var subdivide_count_LOD2 = 128:
	get: return subdivide_count_LOD2
	set(value):
		subdivide_count_LOD2 = value
		if has_node('TileMeshes/Mesh_LOD2'):
			get_node('TileMeshes/Mesh_LOD2').mesh.subdivide_width = value
			get_node('TileMeshes/Mesh_LOD2').mesh.subdivide_depth = value
			
@export var subdivide_count_LOD3 = 64:
	get: return subdivide_count_LOD3
	set(value):
		subdivide_count_LOD3 = value
		if has_node('TileMeshes/Mesh_LOD3'):
			get_node('TileMeshes/Mesh_LOD3').mesh.subdivide_width = value
			get_node('TileMeshes/Mesh_LOD3').mesh.subdivide_depth = value
			
@export var subdivide_count_LOD4 = 16:
	get: return subdivide_count_LOD4
	set(value):
		subdivide_count_LOD4 = value
		if has_node('TileMeshes/Mesh_LOD4'):
			get_node('TileMeshes/Mesh_LOD4').mesh.subdivide_width = value
			get_node('TileMeshes/Mesh_LOD4').mesh.subdivide_depth = value
			
@export var LOD_visibility_threshold_1 = tile_size:
	get: return LOD_visibility_threshold_1
	set(value):
		LOD_visibility_threshold_1 = value
		if has_node('TileMeshes/Mesh_LOD2'):
			get_node('TileMeshes/Mesh_LOD2').visibility_range_begin = value
		if has_node('TileMeshes/Mesh_LOD1'):
			get_node('TileMeshes/Mesh_LOD1').visibility_range_end = value
			
@export var LOD_visibility_threshold_2 = tile_size * 2:
	get: return LOD_visibility_threshold_2
	set(value):
		LOD_visibility_threshold_2 = value
		if has_node('TileMeshes/Mesh_LOD3'):
			get_node('TileMeshes/Mesh_LOD3').visibility_range_begin = value
		if has_node('TileMeshes/Mesh_LOD2'):
			get_node('TileMeshes/Mesh_LOD2').visibility_range_end = value
			
@export var LOD_visibility_threshold_3 = tile_size * 3:
	get: return LOD_visibility_threshold_3
	set(value):
		LOD_visibility_threshold_3 = value
		if has_node('TileMeshes/Mesh_LOD4'):
			get_node('TileMeshes/Mesh_LOD4').visibility_range_begin = value
		if has_node('TileMeshes/Mesh_LOD3'):
			get_node('TileMeshes/Mesh_LOD3').visibility_range_end = value
			
@export var LOD_visibility_end = tile_size * 10:
	get: return LOD_visibility_end
	set(value):
		LOD_visibility_end = value
		if has_node('TileMeshes/Mesh_LOD4'):
			get_node('TileMeshes/Mesh_LOD4').visibility_range_end = value
		
# Called when the node enters the scene tree for the first time.
func _ready():
	tile_meshes = get_node('TileMeshes').get_children()
	collision_shape = get_node('CollisionShape3D')
	update_tile_size()
	update_lod_params()
	update_shader_material()
	set_shader_param('tile_size', tile_size)

func update_tile_size():
	collision_shape.shape.size.x = tile_size
	collision_shape.shape.size.z = tile_size
	for c in tile_meshes:
		c.mesh.size.x = tile_size
		c.mesh.size.y = tile_size
	
func update_shader_material():
	for c in tile_meshes:
		c.mesh.set_material(shader_material)
		
func set_shader_param(param_name, param_value):
	for c in tile_meshes:
		c.mesh.get_material().set_shader_param(param_name, param_value)

func update_lod_params():
	for c in tile_meshes:
		if 'LOD1' in c.name:
			c.mesh.subdivide_width = subdivide_count_LOD1
			c.mesh.subdivide_depth = subdivide_count_LOD1
			c.visibility_range_begin = 0
			c.visibility_range_end = LOD_visibility_threshold_1
		elif 'LOD2' in c.name:
			c.mesh.subdivide_width = subdivide_count_LOD2
			c.mesh.subdivide_depth = subdivide_count_LOD2
			c.visibility_range_begin = LOD_visibility_threshold_1
			c.visibility_range_end = LOD_visibility_threshold_2
		elif 'LOD3' in c.name:
			c.mesh.subdivide_width = subdivide_count_LOD3
			c.mesh.subdivide_depth = subdivide_count_LOD3
			c.visibility_range_begin = LOD_visibility_threshold_2
			c.visibility_range_end = LOD_visibility_threshold_3
		elif 'LOD4' in c.name:
			c.mesh.subdivide_width = subdivide_count_LOD4
			c.mesh.subdivide_depth = subdivide_count_LOD4
			c.visibility_range_begin = LOD_visibility_threshold_3
			c.visibility_range_end = LOD_visibility_end
