uniform float cb_strength = 1.0;
uniform float cb_bottom = 0.0;
uniform float cb_height = 1.0;
uniform float cb_amplitude = 0.04;
uniform float cb_time_override = -1.0;
vec3 cb_wind(vec3 p, mat4 model, float engine_time) {
 float t = cb_time_override >= 0.0 ? cb_time_override : engine_time;
 vec3 anchor = model[3].xyz;
 float phase = dot(anchor.xz, vec2(0.73, 0.49));
 float gust = 0.68 + 0.32 * sin(t * 0.79 - phase * 0.22);
 float wave = sin(t * 1.45 + phase) + 0.22 * sin(t * 2.6 + phase * 1.7);
 float weight = pow(clamp((p.y - cb_bottom) / max(cb_height, 0.01), 0.0, 1.0), 1.8);
 vec3 world_offset = vec3(0.89, 0.0, 0.45) * wave * gust * weight * cb_amplitude * cb_strength;
 return p + inverse(mat3(model)) * world_offset;
}
