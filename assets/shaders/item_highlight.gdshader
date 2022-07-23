shader_type spatial;
render_mode blend_mix;

// Interact shader highlight color
uniform vec4 highlight_color : source_color = vec4(1, 0.89, 0, 0.1);
uniform float emission_intensity = 1;

// Interact shader highlight strength
//uniform float strength;

void fragment() {
	ALBEDO = highlight_color.rgb;
	ALPHA = highlight_color.a;
	EMISSION = ALBEDO * emission_intensity;
}
