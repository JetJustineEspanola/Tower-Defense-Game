extends Node3D
static var sound_window_ms: int = -1000
static var sounds_in_window: int = 0
const HIT = preload("res://assets/audio/combat/hit.tres")
const FALL = preload("res://assets/audio/combat/fall.tres")
const BASE = preload("res://assets/audio/combat/base.tres")
func play(damage: int, defeated: bool, base_hit: bool) -> void:
	if base_hit and defeated: process_mode = Node.PROCESS_MODE_ALWAYS
	$Number.text = ("BASE  −%d" if base_hit else "−%d") % damage
	$Number.modulate = Color("#ff637c") if base_hit else Color("#fff2bc")
	$Number.font_size = 44 if base_hit else 32
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	$Burst.emitting = experience == null or not experience.reduced_effects
	$Sound.bus = &"SFX"
	var now: int = Time.get_ticks_msec()
	if now - sound_window_ms >= 60:
		sound_window_ms = now
		sounds_in_window = 0
	# Allow simultaneous hits without one guard hit silencing all tower impacts.
	if base_hit or sounds_in_window < 4:
		sounds_in_window += 1
		$Sound.stream = BASE if base_hit else (FALL if defeated else HIT)
		$Sound.pitch_scale = randf_range(0.94, 1.06)
		$Sound.play()
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 0.55, 0.75)
	tween.tween_property($Number, "modulate:a", 0.0, 0.45).set_delay(0.3)
	tween.chain().tween_callback(queue_free)
