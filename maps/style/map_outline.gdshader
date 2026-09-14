shader_type spatial;
render_mode cull_front, unshaded, shadows_disabled;
uniform vec4 outline_color : source_color = vec4(0.018, 0.038, 0.055, 1.0);
uniform float thickness = 0.009;
void vertex() {
 float world_scale = max(length((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz), 0.001);
 VERTEX += NORMAL * thickness / world_scale;
}
void fragment() { ALBEDO = outline_color.rgb; }
