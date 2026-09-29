@tool
extends Node
## Styles local material copies, preserving imported textures, rigs and animations.
@export var model_path: NodePath = ^"../Model"
@export_range(0.001, 0.02, 0.001) var outline_width: float = 0.004:
	set(value):
		outline_width = value
		if is_inside_tree(): call_deferred("apply_style")
@export_range(0.0, 1.0, 0.05) var minimum_roughness: float = 0.7:
	set(value):
		minimum_roughness = value
		if is_inside_tree(): call_deferred("apply_style")
const OUTLINE: Shader = preload("res://maps/style/map_outline.gdshader")
var sources: Dictionary = {}
var styled_surface_count: int = 0

func _ready() -> void:
	apply_style()

func apply_style() -> void:
	if not is_inside_tree(): return
	var model: Node = get_node_or_null(model_path)
	if model == null: return
	styled_surface_count = 0
	var cache: Dictionary = {}
	for node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh == null: continue
		if str(mesh_node.name).to_lower().contains("outline"): continue
		for surface in mesh_node.mesh.get_surface_count():
			var key: String = "%s:%d" % [mesh_node.get_instance_id(), surface]
			if not sources.has(key):
				sources[key] = mesh_node.get_active_material(surface)
			var source: Material = sources[key]
			if not source is BaseMaterial3D: continue
			var base := source as BaseMaterial3D
			# Preserve transparent hair cards, eyes, glass, and glow materials.
			if base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED: continue
			var material_key: int = source.get_instance_id()
			if not cache.has(material_key):
				var styled: BaseMaterial3D = base.duplicate()
				styled.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
				styled.specular_mode = BaseMaterial3D.SPECULAR_TOON
				styled.roughness = maxf(base.roughness, minimum_roughness)
				styled.metallic = minf(base.metallic, 0.15)
				if base.next_pass == null and not base.emission_enabled:
					var outline := ShaderMaterial.new()
					outline.shader = OUTLINE
					outline.set_shader_parameter("thickness", outline_width)
					outline.set_shader_parameter("outline_color", Color(0.025, 0.028, 0.045))
					styled.next_pass = outline
				cache[material_key] = styled
			if mesh_node.material_override != null:
				mesh_node.material_override = cache[material_key]
			else:
				mesh_node.set_surface_override_material(surface, cache[material_key])
			styled_surface_count += 1
		# Prevent the map's generic pass from adding a second outline.
		mesh_node.set_meta("map_outline_done", true)
