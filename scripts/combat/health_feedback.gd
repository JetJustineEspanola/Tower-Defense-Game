extends Node3D
@export var track_parent_health: bool = true
@export var healthy_color: Color = Color("#42dfcf")
const POPUP = preload("res://scenes/combat/damage_popup.tscn")
var meshes: Array[MeshInstance3D] = []
var originals: Array[Material] = []
var flash_time: float = 0.0
var flash := StandardMaterial3D.new()
func _ready() -> void:
	set_health(100, 100)
	flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	flash.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash.albedo_color = Color(1.0, 0.8, 0.6, 0.75)
	var model = get_parent().get_node_or_null("Model")
	if model:
		for mesh in model.find_children("*", "MeshInstance3D", true, false):
			meshes.append(mesh)
			originals.append(mesh.material_overlay)
	var old_label = get_parent().get_node_or_null("Health")
	if old_label: old_label.hide()
	var old_name = get_parent().get_node_or_null("NameLabel")
	if old_name: old_name.hide()
func _process(delta: float) -> void:
	if track_parent_health:
		set_health(get_parent().health, get_parent().maximum_health)
	if flash_time > 0:
		flash_time -= delta
		if flash_time <= 0:
			for i in meshes.size():
				if is_instance_valid(meshes[i]): meshes[i].material_overlay = originals[i]
func set_health(current: int, maximum: int) -> void:
	var ratio: float = clampf(float(current) / maxi(1, maximum), 0.0, 1.0)
	# Crop in billboard pixel space so the left edge stays fixed even as actors turn.
	var width: float = $Fill.texture.get_width()
	var filled_width: float = width * ratio
	$Fill.region_rect = Rect2(0, 0, filled_width, $Fill.texture.get_height())
	$Fill.offset.x = (filled_width - width) * 0.5
	$Fill.visible = current > 0
	$Fill.modulate = healthy_color if ratio > 0.5 else (Color("#ffc55c") if ratio > 0.25 else Color("#ff5268"))
	$Value.text = "%d / %d" % [current, maximum]
func hit(before: int, after: int, base_hit: bool = false) -> void:
	var online = get_tree().current_scene
	if online != null and online.has_method("record_visual"): online.record_visual(get_parent(), "hit", {"before": before, "after": after})

	var actual: int = before - after
	if actual <= 0: return
	var popup = POPUP.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.global_position = global_position + Vector3.UP * 0.4
	popup.play(actual, after == 0, base_hit)
	flash_time = 0.18
	for mesh in meshes:
		if is_instance_valid(mesh): mesh.material_overlay = flash
