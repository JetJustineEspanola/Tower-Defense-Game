shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, depth_draw_never, shadows_disabled;
void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX[0].xyz *= length(MODEL_MATRIX[0].xyz);
	MODELVIEW_MATRIX[1].xyz *= length(MODEL_MATRIX[1].xyz);
}
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float edge = length(p) + 0.09 * sin(p.x * 17.0 + p.y * 8.0) * sin(p.y * 13.0);
	float puff = 1.0 - smoothstep(0.25, 1.0, edge);
	ALBEDO = mix(vec3(0.28, 0.35, 0.39), vec3(0.8, 0.88, 0.85), UV.y);
	ALPHA = puff * COLOR.a * 0.55;
}
