extends VisibleOnScreenNotifier3D
## Cosmetic-only frustum gate. Never disables an actor, timer, or gameplay script.
@export var culling_enabled: bool = true
var visibility_known: bool = false
func _ready() -> void:
	screen_entered.connect(_entered)
	screen_exited.connect(_exited)
	call_deferred("_initialize_visibility")
func _initialize_visibility() -> void:
	var tree: SceneTree = get_tree()
	if tree == null: return
	await tree.process_frame
	if not is_inside_tree(): return
	await tree.process_frame
	if not is_inside_tree(): return
	visibility_known = true
func allows_burst() -> bool:
	return not culling_enabled or not visibility_known or is_on_screen() or DisplayServer.get_name() == "headless"
func _entered() -> void:
	visibility_known = true
func _exited() -> void:
	visibility_known = true
	if not culling_enabled: return
	for child in get_parent().get_children():
		if child is CPUParticles3D:
			child.emitting = false
