shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never;
uniform float integrity = 1.0;
uniform float impact = 0.0;
void fragment() {
	vec3 cool = vec3(0.12, 0.7, 1.0);
	vec3 danger = vec3(1.0, 0.12, 0.22);
	vec3 color = mix(danger, cool, smoothstep(0.1, 0.65, integrity));
	float seam = pow(abs(sin(UV.x * 37.0 + sin(UV.y * 23.0) * 2.0)), 35.0);
	float bands = pow(abs(sin(UV.y * 35.0)), 30.0);
	ALBEDO = color;
	EMISSION = color * (0.25 + impact * 2.0);
	ALPHA = clamp(0.025 + impact * 0.26 + (seam + bands) * (1.0 - integrity) * 0.26, 0.0, 0.65);
}
