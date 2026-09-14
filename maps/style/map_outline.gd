@tool
extends Node
## Scene-local outline pass. Original asset resources and colors stay untouched.
const OUTLINE = preload("res://maps/style/map_outline.gdshader")
var _cache: Dictionary = {}
var _counts: Dictionary = {}

func _ready() -> void:
	call_deferred("apply_outlines")

func apply_outlines() -> void:
	_counts = {"added_surfaces": 0, "existing_outline_meshes": 0, "effect_surfaces_preserved": 0}
	_walk(get_parent())
	print("MAP_OUTLINE_AUDIT ", JSON.stringify(_counts))

func _walk(node: Node) -> void:
	if node is MeshInstance3D and node.mesh:
		_style(node)
	for child in node.get_children():
		_walk(child)

func _style(mesh_node: MeshInstance3D) -> void:
	if mesh_node.name.to_lower().contains("outline") or mesh_node.has_meta("map_outline_done"):
		return
	# These originals already have a separate inverted hull; do not double it.
	if mesh_node.has_node("OutlineHull") or (mesh_node.get_parent().has_node("OutlineHull") and mesh_node.get_parent().get_node("OutlineHull") != mesh_node):
		_counts.existing_outline_meshes += 1
		return
	for surface in mesh_node.mesh.get_surface_count():
		var original: Material = mesh_node.get_active_material(surface)
		if not original:
			continue
		var label: String = (str(mesh_node.name) + " " + original.resource_name).to_lower()
		if _effect(label) or (original is BaseMaterial3D and original.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED):
			_counts.effect_surfaces_preserved += 1
			continue
		if original is ShaderMaterial and original.shader and original.shader.code.contains("cull_front"):
			continue
		# Preserve existing next-pass chains rather than replacing them.
		if original.next_pass:
			_counts.existing_outline_meshes += 1
			continue
		var width: float = 0.008
		if label.contains("grass_tile") or label.contains("dirt") or label.contains("underlay") or label.contains("path"):
			width = 0.002
		elif label.contains("flower") or label.contains("grass") or label.contains("energy") or label.contains("rune"):
			width = 0.004
		var key: String = str(original.get_instance_id()) + ":" + str(width)
		if not _cache.has(key):
			var local: Material = original.duplicate()
			var hull := ShaderMaterial.new()
			hull.shader = OUTLINE
			hull.set_shader_parameter("thickness", width)
			local.next_pass = hull
			_cache[key] = local
		if mesh_node.material_override:
			mesh_node.material_override = _cache[key]
			_counts.added_surfaces += 1
			break
		mesh_node.set_surface_override_material(surface, _cache[key])
		_counts.added_surfaces += 1
	mesh_node.set_meta("map_outline_done", true)

func _effect(label: String) -> bool:
	for word in ["water", "foam", "splash", "ripple", "glow", "flame", "glass"]:
		if label.contains(word):
			return true
	return false
