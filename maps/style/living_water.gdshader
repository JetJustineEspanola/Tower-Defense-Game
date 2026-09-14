shader_type spatial;
render_mode unshaded, cull_disabled;
uniform bool falling = false;
uniform bool foam = false;
uniform float flow_direction = 1.0;
uniform float cb_time_override = -1.0;
varying vec3 world_p;
void vertex(){world_p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){
 float t=cb_time_override>=0.0?cb_time_override:TIME;
 float flow_t=t*flow_direction;
 vec3 blue=vec3(0.035,0.30,0.57);
 vec3 cyan=vec3(0.08,0.53,0.76);
 vec3 pale=vec3(0.48,0.83,0.91);
 if(foam){
  ALBEDO=mix(vec3(0.64,0.87,0.91),vec3(0.91,0.98,0.96),0.65+0.15*sin(flow_t*1.8+world_p.x*2.0+world_p.z));
 }else if(falling){
  float across=world_p.x+world_p.z;
  float ribbons=sin(across*7.0+sin(across*2.3)*1.2);
  float drops=sin(world_p.y*5.0+t*3.4+across*2.0);
  float band=smoothstep(0.30,0.45,ribbons);
  ALBEDO=mix(blue,cyan,0.35+0.65*band);
  ALBEDO=mix(ALBEDO,pale,smoothstep(0.84,0.94,drops)*band*0.65);
 }else{
  float drift=world_p.x*1.6+world_p.z*2.9+flow_t*0.65;
  float broad=sin(drift+sin(world_p.x*2.1-world_p.z)*0.8);
  float streak=smoothstep(0.91,0.98,broad);
  ALBEDO=mix(blue,cyan,0.70+0.12*sin(drift*.52));
  ALBEDO=mix(ALBEDO,pale,streak*0.42);
 }
}
