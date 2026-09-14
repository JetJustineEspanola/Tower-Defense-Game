@tool
extends Node
## Shared GPU wind; local material copies preserve the source assets and backup.
@export_range(0.0, 2.0, 0.05) var wind_strength: float = 1.0:
	set(value):
		wind_strength=value
		for material in _materials: material.set_shader_parameter("cb_strength",value)
const WATER=preload("res://maps/style/living_water.gdshader")
const BACKGROUND_MUSIC=preload("res://assets/audio/music/CODE_BORN_Crystalbrook_Vigil_Loop.wav")
@export_range(-30.0, 0.0, 0.5) var music_volume_db: float = -5.0
var _materials: Array[ShaderMaterial]=[]
var _shader_cache: Dictionary={}
var _cache: Dictionary={}
var audit: Dictionary={"plants":0,"moving_outlines":0,"water_surfaces":0,"reversed_lower_water":0}

func _ready() -> void:
	if Engine.is_editor_hint():
		call_deferred("_stop_editor_music")
	else:
		call_deferred("_start_background_music")
	call_deferred("_setup")

func _stop_editor_music() -> void:
	var player=get_parent().get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if player:
		player.stop()
		# Runtime-created players have no scene owner and should not linger in
		# the editor after this script is reloaded.
		if not player.owner:player.queue_free()

func _start_background_music() -> void:
	if Engine.is_editor_hint():return
	var player=get_parent().get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if not player:
		player=AudioStreamPlayer.new()
		player.name="BackgroundMusic"
		get_parent().add_child(player)
	player.process_mode=Node.PROCESS_MODE_ALWAYS
	player.stream=BACKGROUND_MUSIC
	player.volume_db=music_volume_db
	player.bus="Master"
	if not player.finished.is_connected(_restart_music):
		player.finished.connect(_restart_music)
	player.play()
	print("BACKGROUND_MUSIC_STARTED volume_db=",player.volume_db," length=",player.stream.get_length())

func _restart_music() -> void:
	var player=get_parent().get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if player:player.play()

func _plant(name_text: String) -> bool:
	for word in ["tree", "grass_clump", "grass_flower", "shrub", "flower", "small_plant", "sapling", "bush"]:
		if name_text.contains(word):return true
	return false

func _setup() -> void:
	# Outline controller is earlier in the scene and has now finished its pass.
	var meshes=get_parent().find_children("*","MeshInstance3D",true,false)
	var plant_meshes: Dictionary={}
	for node in meshes:
		if node.mesh and _plant(str(node.name).to_lower()):plant_meshes[node.mesh.get_instance_id()]=true
	for node in meshes:
		if not node.mesh or node.has_meta("living_applied"):continue
		var label=str(node.name).to_lower()
		var hull=label.contains("outline")
		var plant=_plant(label) or (hull and plant_meshes.has(node.mesh.get_instance_id()))
		if plant:
			var box: AABB=node.get_aabb()
			var amplitude=0.045 if box.size.y>1.0 else 0.018
			if node.material_override:
				node.material_override=_wind_material(node.material_override,box,amplitude)
			else:
				for i in node.mesh.get_surface_count():
					var m=node.get_active_material(i)
					if m:node.set_surface_override_material(i,_wind_material(m,box,amplitude))
			node.extra_cull_margin=maxf(node.extra_cull_margin,0.12)
			audit["moving_outlines" if hull else "plants"]+=1
		else:
			for i in node.mesh.get_surface_count():
				var source=node.get_active_material(i)
				if not source:continue
				var raw=node.mesh.surface_get_material(i)
				var names=(source.resource_name+" "+(raw.resource_name if raw else "")).to_lower()
				if names.contains("water") or names.contains("foam"):
					var is_foam=names.contains("foam") or names.contains("water_light")
					var is_fall=label.contains("waterfall") and not label.contains("edge")
					# The ground-level east channel is fed from the opposite end of the
					# upper channel, so its horizontal highlights travel in reverse.
					var reverse_lower=(not is_fall and node.global_position.x>10.0 and node.global_position.y<1.0)
					var key="water_%s_%s_%s"%[is_foam,is_fall,reverse_lower]
					if not _cache.has(key):
						var material=ShaderMaterial.new()
						material.shader=WATER
						material.set_shader_parameter("foam",is_foam)
						material.set_shader_parameter("falling",is_fall)
						material.set_shader_parameter("flow_direction",-1.0 if reverse_lower else 1.0)
						_cache[key]=material
						_materials.append(material)
					if node.material_override:node.material_override=_cache[key]
					else:node.set_surface_override_material(i,_cache[key])
					audit.water_surfaces+=1
					if reverse_lower:audit.reversed_lower_water+=1
		node.set_meta("living_applied",true)
	print("LIVING_AUDIT ",JSON.stringify(audit))

func _wind_material(source: Material, box: AABB, amplitude: float) -> Material:
	var key=str(source.get_instance_id())+str(box)+str(amplitude)
	if _cache.has(key):return _cache[key]
	var material: ShaderMaterial
	if source is ShaderMaterial:
		material=source.duplicate()
		var code=source.shader.code
		if not _shader_cache.has(code):
			var shader=Shader.new()
			var insertion=code.find("void ")
			if insertion<0:return source
			code=code.insert(insertion,"\n#include \"res://maps/style/living_wind.gdshaderinc\"\n")
			var vertex=code.find("void vertex")
			if vertex>=0:
				var brace=code.find("{",vertex)
				code=code.insert(brace+1,"VERTEX=cb_wind(VERTEX,MODEL_MATRIX,TIME);")
			else:code+="\nvoid vertex(){VERTEX=cb_wind(VERTEX,MODEL_MATRIX,TIME);}\n"
			shader.code=code
			_shader_cache[source.shader.code]=shader
		material.shader=_shader_cache[source.shader.code]
	else:
		material=ShaderMaterial.new()
		if not _shader_cache.has("standard"):
			var shader=Shader.new()
			shader.code="shader_type spatial;\nrender_mode cull_disabled,specular_disabled;\nuniform vec4 base_color:source_color;\n#include \"res://maps/style/living_wind.gdshaderinc\"\nvoid vertex(){VERTEX=cb_wind(VERTEX,MODEL_MATRIX,TIME);}\nvoid fragment(){ALBEDO=base_color.rgb;ROUGHNESS=1.;}\nvoid light(){float d=max(dot(NORMAL,LIGHT),0.)*ATTENUATION;float b=d>.63?.96:(d>.22?.68:.30);DIFFUSE_LIGHT+=b*LIGHT_COLOR/3.14159265;}"
			_shader_cache["standard"]=shader
		material.shader=_shader_cache["standard"]
		material.set_shader_parameter("base_color",source.albedo_color if source is BaseMaterial3D else Color.WHITE)
	material.set_shader_parameter("cb_bottom",box.position.y)
	material.set_shader_parameter("cb_height",box.size.y)
	material.set_shader_parameter("cb_amplitude",amplitude)
	material.set_shader_parameter("cb_strength",wind_strength)
	_cache[key]=material
	_materials.append(material)
	if source.next_pass:material.next_pass=_wind_material(source.next_pass,box,amplitude)
	return material

func set_preview_time(seconds: float) -> void:
	for material in _materials:material.set_shader_parameter("cb_time_override",seconds)
