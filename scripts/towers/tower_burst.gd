extends Node3D
## Scene-authored Godot particle emitters; never grants gameplay rewards.
var pulse: Tween
var popup_origin: Vector3
@export var coins_per_ten_gold: int = 28
@export var maximum_coin_particles: int = 70
@export var slash_duration: float = 0.32
var burning: bool = false
var attack_distance: float = 1.0

func configure_attack(damage_ratio: float, extra_targets: int, burns: bool, cadence_ratio: float) -> void:
	var slash: CPUParticles3D = get_node_or_null("RedSlash")
	if slash == null: return
	burning = burns
	# Only emitter properties change; imported/shared materials remain untouched.
	var strength: float = clampf(sqrt(damage_ratio), 1.0, 1.6)
	slash.scale_amount_min = 0.7 * strength
	slash.scale_amount_max = strength
	slash.amount = mini(5, 2 + extra_targets)
	slash.scale.x = 1.0 + minf(extra_targets * 0.2, 0.6)
	slash.lifetime = slash_duration * clampf(cadence_ratio, 0.65, 1.0)

func aim_attack(distance: float) -> void:
	attack_distance = distance
	var slash: CPUParticles3D = get_node_or_null("RedSlash")
	if slash == null: return
	# The visible arc reaches the struck enemy, including Long Reach targets.
	var speed: float = maxf(0.2, distance) / maxf(0.1, slash.lifetime * 0.8)
	slash.initial_velocity_min = speed
	slash.initial_velocity_max = speed

func configure_summon(count: int) -> void:
	var smoke: CPUParticles3D = get_node_or_null("Smoke")
	if smoke != null:
		smoke.amount = clampi(28 * count, 28, 56)
@onready var popup: Label3D = get_node_or_null("GoldPopup")
func _ready() -> void:
	if popup != null:
		popup_origin = popup.position
func play(amount: int = 0) -> void:
	var online = get_tree().current_scene
	if online != null and online.has_method("record_visual"):
		online.record_visual(get_parent(), "effect", {"path": str(name), "amount": amount, "distance": attack_distance, "position": [global_position.x, global_position.y, global_position.z], "rotation": [global_rotation.x, global_rotation.y, global_rotation.z]})
	var visibility_gate = get_node_or_null("Visibility")
	if visibility_gate != null and not visibility_gate.allows_burst(): return
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	var reduced: bool = experience != null and experience.reduced_effects
	var coins: CPUParticles3D = get_node_or_null("Coins")
	if coins != null:
		coins.amount = clampi(roundi(coins_per_ten_gold * amount / 10.0), 6, maximum_coin_particles)
	for child in get_children():
		if child is CPUParticles3D:
			if reduced and child.name != "RedSlash": continue
			if child.name == "Embers" and not burning:
				continue
			child.restart()
			child.emitting = true
	if popup == null:
		return
	if pulse != null and pulse.is_valid():
		pulse.kill()
	popup.text = "+%d Gold" % amount
	popup.position = popup_origin
	popup.transparency = 0.0
	popup.visible = true
	pulse = create_tween().set_parallel(true)
	pulse.tween_property(popup, "position", popup_origin + Vector3.UP * 0.5, 0.9)
	pulse.tween_property(popup, "transparency", 1.0, 0.35).set_delay(0.55)
	pulse.chain().tween_callback(func() -> void: popup.visible = false)
