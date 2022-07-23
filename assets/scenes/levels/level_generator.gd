extends Node3D

@export var tile_scene: PackedScene
@export var tile_size: float = 4
@export var torch_scene: PackedScene
@export var torch_height = 2
@export var torch_placement_randomness = 0.05
@export var torch_distance_from_wall = 0.3
@export var wood_beam_scene: PackedScene
@export var wood_beam_offset = 0.1
@export var fog_tile_scene: PackedScene
var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var nodes = []
	var z_coords = range(3)
	var z_scaled
	var tile_center
	for i in range(z_coords.size() + 1):
		if i < z_coords.size():
			z_scaled = tile_size * z_coords[i]
			tile_center = Vector3(0, 0, z_scaled)
			add_tiles(tile_center, Vector3(0, 0, 0))
			add_beam_arch(tile_center - Vector3(0, 0, tile_size / 2), Vector3(0, 0, 0))
			add_fog(tile_center)
			
			# Add torches only every other tile
			if i % 2 != 0:
				add_torches(tile_center, Vector3(0, 0, 0))
		
		# Add one wood beam arch at the end of the last tile
		else:
			add_beam_arch(tile_center + Vector3(0, 0, tile_size / 2), Vector3(0, 0, 0))
		
	for node in nodes:
		add_child(node)

func add_tiles(pos: Vector3, rot: Vector3) -> void:
	var floor_tile = tile_scene.instantiate()
	var ceiling_tile = tile_scene.instantiate()
	var wall_left = tile_scene.instantiate()
	var wall_right = tile_scene.instantiate()
	floor_tile.set_position(pos)
	ceiling_tile.set_position(pos + Vector3(0, tile_size, 0))
	ceiling_tile.set_rotation(rot + Vector3(0, 0, deg2rad(180)))
	wall_left.set_position(pos + Vector3(tile_size / 2, tile_size / 2, 0))
	wall_left.set_rotation(rot + Vector3(0, 0, deg2rad(90)))
	wall_right.set_position(pos + Vector3(-tile_size / 2, tile_size / 2, 0))
	wall_right.set_rotation(rot + Vector3(0, 0, deg2rad(-90)))
	add_child(floor_tile)
	add_child(ceiling_tile)
	add_child(wall_left)
	add_child(wall_right)

func add_beam_arch(pos: Vector3, rot: Vector3) -> void:
	var wood_beam_top = wood_beam_scene.instantiate()
	var wood_beam_left = wood_beam_scene.instantiate()
	var wood_beam_right = wood_beam_scene.instantiate()
	wood_beam_top.set_position(pos + Vector3(0, tile_size - wood_beam_offset, 0))
	wood_beam_left.set_position(pos + Vector3(tile_size / 2 - wood_beam_offset, tile_size / 2, 0))
	wood_beam_left.set_rotation(rot + Vector3(0, 0, deg2rad(90)))
	wood_beam_right.set_position(pos + Vector3(-tile_size / 2 + wood_beam_offset, tile_size / 2, 0))
	wood_beam_right.set_rotation(rot + Vector3(0, 0, deg2rad(-90)))
	add_child(wood_beam_top)
	add_child(wood_beam_left)
	add_child(wood_beam_right)

func add_torches(pos: Vector3, rot: Vector3) -> void:
	var torch_left = torch_scene.instantiate()
	var torch_right = torch_scene.instantiate()
	torch_left.set_position(pos + Vector3(
		tile_size / 2 - torch_distance_from_wall,
		torch_height + rng.randf_range(-torch_placement_randomness, torch_placement_randomness),
		rng.randf_range(-torch_placement_randomness, torch_placement_randomness)
	))
	torch_left.set_rotation(rot + Vector3(0, deg2rad(90), 0))
	torch_right.set_position(pos + Vector3(
		-(tile_size / 2 - torch_distance_from_wall),
		torch_height + rng.randf_range(-torch_placement_randomness, torch_placement_randomness),
		rng.randf_range(-torch_placement_randomness, torch_placement_randomness)
	))
	torch_right.set_rotation(rot + Vector3(0, deg2rad(-90), 0))
	add_child(torch_left)
	add_child(torch_right)

func add_fog(pos: Vector3) -> void:
	var fog_tile = fog_tile_scene.instantiate()
	fog_tile.set_position(pos + Vector3(0, fog_tile.extents.y / 2, 0))
	add_child(fog_tile)
