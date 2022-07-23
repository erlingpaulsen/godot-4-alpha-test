// ANCHOR: all
// This shader is based on Minionsart's stylized fire
// https://twitter.com/minionsart/status/1132593681452683264?s=20
shader_type spatial;
render_mode blend_mix;

uniform sampler2D noise_texture;
uniform float emission_intensity = 2.0;
uniform vec2 texture_scale = vec2(1.0);
uniform float edge_softness = 0.1;
instance uniform float seed;

varying vec3 world_coord;
varying float world_x_dot;


void vertex() {
	// ANCHOR: matworld_1
	// Billboard code, taken directly from a spatial material
	// create a spatial material, enable billboard with billboard keep scale, and then convert
	// to shader material, and it will create a shader with this code.
	mat4 mat_world = mat4(
			normalize(INV_VIEW_MATRIX[0]) * length(MODEL_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[1]) * length(MODEL_MATRIX[0]),
			normalize(INV_VIEW_MATRIX[2]) * length(MODEL_MATRIX[2]),
			MODEL_MATRIX[3]);
	// END: matworld_1
	// ANCHOR: matworld_2
	mat_world *= mat4(
			vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), 
			vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0),
			vec4(0.0, 0.0, 1.0, 0.0),
			vec4(0.0, 0.0, 0.0, 1.0));
	// END: matworld_2
	// ANCHOR: modelview
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
	// END: modelview
	// ANCHOR: varying_calculations
	// We map the coordinates on the vertical planes xy and zy
	// we also calculate how to blend between the two based on where the world space normal
	// is pointing.
	world_coord = (mat_world * vec4(VERTEX, 1.0)).xyz;
	vec4 world_normal = (mat_world * vec4(NORMAL, 0.0));
	world_x_dot =  abs(dot(normalize(world_normal.xyz), vec3(1.0, 0.0, 0.0)));
	// END: varying_calculations
}

void fragment() {
	vec2 base_uv = UV + seed;
	//vec2 time_based_pan = vec2(-0.1 * cos(0.001 * TIME * horizontal_time_scale) + 0.07 * sin(0.002 * TIME * horizontal_time_scale), 1.0) * (-TIME * vertical_time_scale);
//	vec2 time_based_pan = vec2(0.17 * cos(0.2 * TIME * horizontal_time_scale) + 0.15 * sin(0.2 * TIME * horizontal_time_scale), -TIME * vertical_time_scale);
	vec2 pan_xy = vec2(0.045 * seed * cos(6.38 * TIME), TIME + 0.036 * seed * cos(3.58 * TIME));
	vec2 pan_xz = vec2(0.048 * seed * sin(7.47 * TIME), TIME + 0.025 * seed * cos(2.95 * TIME));

	// We sample the noise both from the xy plane and from the zy plane, adding a time-based
	// panning. If we didn't do this, we would see the holes of the noise will always be in the
	// same space in global coordinates. Set the time_scale to zero to see how it would look like.
	// To add more variation, we could sample from another noise that has a different scale and panning speed.
	// The additional offset on the zy noise is to avoid mirroring effects when
	// the view vector is between same-sign x and z axes
//	float noise_xy = texture(noise_texture, world_coord.xy * texture_scale + time_based_pan).r;
//	float noise_zy = texture(noise_texture, world_coord.zy * texture_scale + time_based_pan + vec2(0.7, 0.3)).r;
	float noise_xy = texture(noise_texture, base_uv * texture_scale + pan_xy).r;
	float noise_zy = texture(noise_texture, base_uv * texture_scale + pan_xz).r;

	// We blend the noise based on world_x_dot, which is the dot product between
	// the normal of the billboard plane, and the global x axis. If we face the global
	// x axis, then we sample from the xy plane, otherwise, we sample from the zy plane
	float noise = mix(noise_xy, noise_zy, clamp(world_x_dot, 0.0, 1.0));

	ALBEDO = COLOR.rgb;
	EMISSION = ALBEDO * emission_intensity;
	float alpha = noise * smoothstep(0.6, 0.0, distance(UV, vec2(0.5, 0.5)));
	alpha += COLOR.a - 1.0;
	alpha = clamp(alpha, 0.0, 1.0);
	ALPHA = smoothstep(0.0, edge_softness, alpha);
}