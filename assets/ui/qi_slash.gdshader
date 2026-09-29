shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never, shadows_disabled;
varying vec2 slash_position;
void vertex() {
	// PlaneMesh lies in XZ. The crescent's convex edge leads along local -Z.
	slash_position = vec2(VERTEX.x, -VERTEX.z) / 0.9;
}
void fragment() {
	vec2 p = slash_position;
	float outer = 1.0 - smoothstep(0.84, 1.0, length(p));
	float inner = smoothstep(0.68, 0.85, length(p - vec2(0.0, -0.32)));
	float taper = smoothstep(-0.55, 0.4, p.y);
	float mask = outer * inner * taper;
	ALBEDO = vec3(1.0, 0.025, 0.055);
	EMISSION = vec3(0.6, 0.0, 0.015);
	ALPHA = mask * COLOR.a;
}
