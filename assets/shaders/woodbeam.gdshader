shader_type spatial;

uniform sampler2D height_noise;
uniform sampler2D noise;
uniform sampler2D normalmap;
uniform float beam_length = 4;
uniform float beam_thickness = 0.2;
uniform float height_scale = 0.02;
uniform float height_offset = 0.01;
uniform vec3 wood_color : source_color = vec3(0.5, 0.46, 0.33);
uniform vec3 wood_color_2 : source_color = vec3(0.5, 0.46, 0.33);
uniform float color_mix_curve : hint_range(0.1, 5.0, 0.05) = 1.0;
uniform float brightness : hint_range(0.5, 1.5, 0.01) = 1.0;
instance uniform float seed;

vec2 get_rotation(float x) {
	float dropoff = smoothstep(0, 0.1, x) * smoothstep(1.0, 0.9, x);
	float w1 = 0.008 * cos(7.36 * x) + 0.009 * sin(15.48 * x) + 0.005* cos(27.36 * x);
	float w2 = 0.008 * cos(8.57 * x) + 0.009 * sin(12.48 * x) + 0.005 * cos(33.36 * x);
	w1 = mix(0.0, w1, dropoff);
	w2 = mix(0.0, w2, dropoff);
	return vec2(w1, w2);
}

void vertex() {
	// Texture position on top and bottom faces
	vec2 tex_position_tb = vec2(VERTEX.x / beam_length + 0.5, VERTEX.z / beam_thickness + 0.5);
	// Texture position on left and right faces
	vec2 tex_position_lr = vec2(VERTEX.x / beam_length + 0.5, VERTEX.y / beam_thickness + 0.5);
	
	// Let height displacement drop off near edges
	float dropoff_x = pow(smoothstep(-beam_length / 2.0, -beam_length / 2.0 + 0.01, VERTEX.x), 0.5) * pow(smoothstep(beam_length / 2.0, beam_length / 2.0 - 0.01, VERTEX.x), 0.5);
	float dropoff_y = pow(smoothstep(-beam_thickness / 2.0, -beam_thickness / 2.0 + 0.01, VERTEX.y), 0.5) * pow(smoothstep(beam_thickness / 2.0, beam_thickness / 2.0 - 0.01, VERTEX.y), 0.5);
	float dropoff_z = pow(smoothstep(-beam_thickness / 2.0, -beam_thickness / 2.0 + 0.01, VERTEX.z), 0.5) * pow(smoothstep(beam_thickness / 2.0, beam_thickness / 2.0 - 0.01, VERTEX.z), 0.5);
	float height = 0.0;
	
	// Need to invert tex_position as the UV scaling causes the texture to be inverted in the XZ-plane compared to the XY-plane
	height = texture(noise, vec2(1.0) - tex_position_tb).x;
	if (VERTEX.y > 0.0) {
		// Change height on top face
		VERTEX.y += height * height_scale * dropoff_x * dropoff_z;
	} else  {
		// Change height on bottom face
		VERTEX.y -= height * height_scale * dropoff_x * dropoff_z;
	}
	
	// Need to invert tex_position as the UV scaling causes the texture to be inverted in the XZ-plane compared to the XY-plane
	height = texture(noise, vec2(1.0) - tex_position_lr).x;
	if (VERTEX.z > 0.0) {
		// Change height on left face
		VERTEX.z += height * height_scale * dropoff_x * dropoff_y;
	} else {
		// Change height on right face
		VERTEX.z -= height * height_scale * dropoff_x * dropoff_y;
	}
	
	// Add rotation
	vec2 rot = get_rotation(tex_position_tb.x + seed);
	VERTEX.y += rot.x;
	VERTEX.z += rot.y;
	
	
	// UV scaling to map noise texture to box mesh
	UV = UV * vec2(3.0, 2.0);
}

void fragment() {
	vec2 base_uv = UV;
	
	float noise_value = texture(noise, base_uv).x;
	vec3 albedo = mix(wood_color, wood_color_2, pow(noise_value, color_mix_curve));
	ALBEDO = pow(albedo, vec3(2.0 - brightness));
	NORMAL_MAP = texture(normalmap, base_uv).xyz;
	ROUGHNESS = 1.0 - pow(clamp(noise_value, 0.0, 0.7), 4.0);
	METALLIC = 0.04;
}