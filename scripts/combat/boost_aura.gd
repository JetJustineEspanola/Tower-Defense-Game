extends Node3D
var duration: float = 6.0
func _process(delta: float) -> void:
	duration -= delta
	if duration <= 0.0: queue_free()
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	visible = experience == null or not experience.reduced_effects
