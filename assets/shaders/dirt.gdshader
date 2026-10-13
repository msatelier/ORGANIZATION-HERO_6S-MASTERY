shader_type spatial;
render_mode cull_disabled;

uniform sampler2D dirt_mask : filter_linear, repeat_disable;
uniform vec3 clean_color : source_color = vec3(0.87, 0.72, 0.50);
uniform vec3 dirt_color : source_color = vec3(0.36, 0.29, 0.20);

void fragment() {
	vec4 dirt = texture(dirt_mask, UV);
	float amount = dirt.a * (0.65 + dirt.r * 0.35);
	ALBEDO = mix(clean_color, dirt_color, amount);
	ROUGHNESS = 0.88;
}
