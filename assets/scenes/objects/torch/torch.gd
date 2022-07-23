class_name Torch extends Interactive

@export var flame_light: OmniLight3D
@export var flame_particles: GPUParticles3D
var flame_particles_material: ParticlesMaterial
@export_range(0.1, 5.0, 0.1, "or_greater", "or_lesser") var base_energy: float = 1.3
var noise = FastNoiseLite.new()
var time: float
var player: CharacterBody3D

func _ready():
	# Creating new noise function with random seed
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_octaves = 4
	noise.frequency = 1.0
	time = 0
	flame_particles.set_shader_instance_uniform('seed', randf())
	flame_particles_material = flame_particles.process_material
	SignalBus.player_initialized.connect(_on_Player_initialized)

func _process(delta):
	# Modulate flame light_energy to cause flickering
	flame_light.light_energy = base_energy + clamp((noise.get_noise_1d(time*0.8) / 1.3), -base_energy, 2 * base_energy)
	if player.velocity.length() > 0:
		flame_particles_material.direction = Vector3.UP - player.velocity
	else:
		flame_particles_material.direction = Vector3.UP
	time += delta

func _on_Player_initialized(player):
	player = player
