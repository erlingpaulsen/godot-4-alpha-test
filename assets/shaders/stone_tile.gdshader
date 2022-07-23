shader_type spatial;
//render_mode diffuse_lambert_wrap;

uniform sampler2D noise : source_color;
uniform sampler2D normal_map : hint_normal;
uniform float normal_map_depth : hint_range(0, 1) = 0.8;
uniform float depth_scale : hint_range(0, 0.05);
uniform float tile_size = 2;
uniform float height_scale : hint_range(0, 0.1) = 0.03;
uniform float height_offset = 0.03;
uniform float height_edge_falloff : hint_range(0, 1) = 0.05;
uniform float height_edge_falloff_curve : hint_range(0.1, 2) = 0.3;
uniform float height_edge_thickness : hint_range(0, 1) = 0.2;
uniform float morter_thickness : hint_range(0, 1) = 0.6;
uniform float morter_placement : hint_range(0, 1) = 0.5;
uniform vec4 stone_color : source_color = vec4(0.5, 0.46, 0.33, 1.0);
uniform float stone_reflection_strength : hint_range(0, 1) = 0.3;
uniform float stone_reflection_start : hint_range(0, 1) = 0.3;
uniform vec4 morter_color : source_color = vec4(0.38, 0.32, 0.2, 1.0);
uniform float albedo_noise_contrast : hint_range(0, 0.1) = 0.02;
uniform float ambient_occlusion_strength : hint_range(0, 1) = 0.5;
uniform vec3 moss_color : source_color = vec3(0.04, 0.15, 0.02);
instance uniform float seed;

// Rotate a vec2
vec2 rotate(vec2 vec, float rot)
{
    float s = sin(rot), c = cos(rot);
    return vec2(vec.x*c-vec.y*s, vec.x*s+vec.y*c);
}

// Hash13 Hash without Sine: https://www.shadertoy.com/view/4djSRW
float hash(vec2 p, float t)
{
    vec3 p3 = vec3(p, t);
    p3  = fract(p3*0.1031);
    p3 += dot(p3, p3.zyx+31.32);
    return fract((p3.x+p3.y)*p3.z);
}
float noise21(vec2 p, float t)
{
    vec4 b = vec4(floor(p), ceil(p));
    vec2 f = smoothstep(0.0, 1.0, fract(p));
    return mix(mix(hash(b.xy, t), hash(b.zy, t), f.x), mix(hash(b.xw, t), hash(b.zw, t), f.x), f.y);
}

// Fractal Brownian Motion Noise
const int num_octaves = 7;
float fbm(vec2 pos)
{
    float value = 0.0;
    float scale = 1.0;
    float atten = 0.5;
    float t = 0.0;
    for(int i = 0; i < num_octaves; i++)
    {
        t += atten;
        value += noise21(pos*scale, float(i))*atten;
        scale *= 2.5;
        atten *= 0.5;
        pos = rotate(pos, 0.125*PI);
    }
    return value/t;
}

void vertex() {
	vec2 tex_position = VERTEX.xz / tile_size + 0.5;
	// Need to invert tex_position as the UV scaling causes the texture to be inverted in the XZ-plane compared to the XY-plane
	float height = texture(noise, vec2(1.0) - tex_position).x;
	
	if (VERTEX.y > 0.0) {
		// Change height on top face
		VERTEX.y += height * height_scale - height_offset;
	} else {
		// Change height on bottom face
		VERTEX.y -= height * height_scale - height_offset;
	}
	
	// Height falloff towards tile edges
	if (height_edge_falloff > 0.0) {
		float dropoff_x = pow(smoothstep(0.0, 0.0 + height_edge_falloff, tex_position.x), height_edge_falloff_curve) * pow(smoothstep(1.0, 1.0 - height_edge_falloff, tex_position.x), height_edge_falloff_curve);
		float dropoff_z = pow(smoothstep(0.0, 0.0 + height_edge_falloff, tex_position.y), height_edge_falloff_curve) * pow(smoothstep(1.0, 1.0 - height_edge_falloff, tex_position.y), height_edge_falloff_curve);
		VERTEX.y = clamp(dropoff_x, height_edge_thickness, 1.0) * clamp(dropoff_z, height_edge_thickness, 1.0) * VERTEX.y;
	}
	
	// UV scaling to map noise texture to box mesh
	UV = UV * vec2(3.0, 2.0);
}

void fragment() {
	float width = 4096.0;
	float height = 4096.0;
	vec2 grid_size = vec2(width, height);
	vec2 base_uv = UV;
	vec2 grid_uv = floor(UV * grid_size) / grid_size;
	vec2 grid_resolution = 1.0 / grid_size;
	
	// Depth
	vec3 view_dir = normalize(normalize(-VERTEX)*mat3(TANGENT,-BINORMAL,NORMAL));
	float depth = 1.0 - texture(noise, base_uv).r;
	vec2 ofs = base_uv - view_dir.xy * depth * depth_scale;
	base_uv=ofs;
	
	// Sampling noise texture
	float noise_value = texture(noise, base_uv).x;
	
	
	// Determining surface color, mix between stone/morter
	float morter_start = clamp(morter_placement - (morter_thickness * 0.5), 0.0, morter_placement);
	float morter_stop = clamp(morter_placement + (morter_thickness * 0.5), morter_placement, 1.0);
	float surface_type = smoothstep(morter_start, morter_stop, noise_value);
	vec3 surface_color = mix(morter_color.rgb, stone_color.rgb, surface_type);
	
	// Sampling fractal brownian motion noise based on world pos for moss generation
	float fbm_noise_scale = 20.0;
	float fbm_noise = fbm(fbm_noise_scale * (UV + seed));
	float fbm_noise_right = fbm(fbm_noise_scale * (UV + vec2(grid_resolution.x, 0.0) + seed));
	float fbm_noise_top = fbm(fbm_noise_scale * (UV - vec2(0.0, grid_resolution.y) + seed));
	
	// Calculating normals for fbm noise
	// See Godot Image class: https://github.com/godotengine/godot/blob/eea14a0edc3f2a8ab4a91d1e142d48a5348584bb/core/io/image.cpp#L3504
	float bump_strength = 30.0;
	vec3 up = vec3(0.0, 1.0, (fbm_noise - fbm_noise_top) * bump_strength);
	vec3 across = vec3(1.0, 0.0, (fbm_noise_right - fbm_noise) * bump_strength);
	vec3 fbm_normal = cross(across, up);
	vec3 fbm_normal_map = vec3(
		(0.5 + fbm_normal.x * 0.5),
		(0.5 + fbm_normal.y * 0.5),
		(0.5 + fbm_normal.z * 0.5)
	);
	
	// Mix moss in surface color based on fbm noise
	float moss_growing = pow(smoothstep(0.5, 0.6, fbm_noise), 0.5) * pow(smoothstep(0.7, 0.6, fbm_noise), 0.5);
	surface_color = mix(surface_color, (moss_color + vec3(0.0304 * fbm_noise, 0.0237 * fbm_noise, 0.0)) * pow(fbm_noise, 0.1), moss_growing);
	ALBEDO = surface_color.rgb + (vec3(noise_value) * albedo_noise_contrast - (albedo_noise_contrast / 2.0));
	
	vec3 normal_map_mix = mix(texture(normal_map, base_uv).xyz, fbm_normal_map, moss_growing);
	NORMAL_MAP = normal_map_mix;
	NORMAL_MAP_DEPTH = normal_map_depth;
	METALLIC = mix(0.1, 0.04, moss_growing);
	float stone_roughness = 1.0 - (smoothstep(stone_reflection_start, 1.0, noise_value) * stone_reflection_strength);
	ROUGHNESS = mix(stone_roughness, 1.0, moss_growing);
	AO_LIGHT_AFFECT = mix(ambient_occlusion_strength, 0.5, moss_growing);
	
	
//	METALLIC = 0.1;
//	ROUGHNESS = 1.0 - (smoothstep(stone_reflection_start, 1.0, noise_value) * stone_reflection_strength);
//	NORMAL_MAP = texture(normal_map, base_uv).xyz;
//	NORMAL_MAP_DEPTH = normal_map_depth;
//	AO_LIGHT_AFFECT = ambient_occlusion_strength;
}
