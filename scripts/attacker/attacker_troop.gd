extends "res://scripts/towers/combat_bug.gd"
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
@export_enum("Nearest", "Economy First", "Strongest", "Weakest") var targeting_priority: int = 0
var post_reserved: bool = false
var post_slot: int = -1
var post_progress: float = 0.0
var stationed: bool = false
var phase_remaining: float = 0.0
var phase_wait: float = 0.0
var auto_siege: bool = true
var siege_remaining: float = 0.0
var shared_remaining: float = 0.0
var tracer_remaining: float = 0.0
var role: String = "objective"
var stats: Dictionary
var resources: PlayerResources
var siege_target: Node3D
var income_elapsed: float = 0.0
var cruise_speed: float
var rush_remaining: float = 0.0
var rush_multiplier: float = 1.5
func _ready() -> void:
	maximum_health = stats.health
	speed = stats.speed
	cruise_speed = speed
	siege_remaining = BALANCE.siege_initial_delay
	super._ready()
	$AttackTimer.wait_time = stats.interval
	add_to_group("attacker_troops")
	_reserve_post()
	for ally in get_tree().get_nodes_in_group("attacker_troops"):
		if ally != self and ally.resources == resources and ally.role == "siege": shared_remaining = maxf(shared_remaining, ally.shared_remaining)
func _physics_process(delta: float) -> void:
	if not alive or clock == null or not clock.running:
		super._physics_process(delta)
		return
	if get_tree().paused: return
	phase_remaining = maxf(0.0, phase_remaining - delta)
	phase_wait = maxf(0.0, phase_wait - delta)
	acquire_blocker()
	if role == "objective" and stats.get("guard_phase", false) and is_instance_valid(blocker) and phase_wait <= 0.0:
		phase_remaining = BALANCE.phase_duration
		phase_wait = BALANCE.phase_cooldown
		acquire_blocker()
	siege_remaining = maxf(0.0, siege_remaining - delta)
	shared_remaining = maxf(0.0, shared_remaining - delta)
	tracer_remaining = maxf(0.0, tracer_remaining - delta)
	$SiegeTracer.visible = tracer_remaining > 0.0
	if role == "siege" and auto_siege: fire_siege()
	rush_remaining = maxf(0.0, rush_remaining - delta)
	speed = cruise_speed * (rush_multiplier if rush_remaining > 0.0 else 1.0) * (BALANCE.phase_speed_multiplier if phase_remaining > 0.0 else 1.0)
	siege_target = null
	if role == "siege" and not is_instance_valid(blocker):
		siege_target = choose_tower(float(stats.attack_range))
		if is_instance_valid(siege_target): speed = 0.0
	if role == "economy":
		income_elapsed += delta
		if income_elapsed >= stats.income_interval:
			income_elapsed -= stats.income_interval
			resources.add_gold(stats.income)
			$IncomeEffect.play(stats.income)
		var leader_progress: float = -1.0
		for ally in get_tree().get_nodes_in_group("attacker_troops"):
			if ally != self and ally.alive and ally.role != "economy":
				leader_progress = maxf(leader_progress, ally.progress)
		if not post_reserved and leader_progress >= 0.0 and progress >= maxf(0.0, leader_progress - 1.0):
			speed = 0.0
	if post_reserved:
		speed = minf(speed, maxf(0.0, post_progress - progress) / maxf(delta, 0.0001))
		stationed = progress >= post_progress - 0.01
	$AbilityStatus.text = "PHASE DASH" if phase_remaining > 0.0 else ("TRADING POST" if stationed else ("TO TRADING POST" if post_reserved else ""))
	$AbilityStatus.visible = not $AbilityStatus.text.is_empty()
	super._physics_process(delta)
	if alive and is_instance_valid(siege_target):
		$CharacterAnimation.face_towards(siege_target.global_position)
func _attack() -> void:
	if role != "siege" or not alive or clock == null or not clock.running: return
	acquire_blocker()
	var target: Node3D = blocker if is_instance_valid(blocker) else siege_target
	if is_instance_valid(target) and target.health > 0:
		if $CharacterAnimation.play_action(stats.interval * 0.75):
			pending_target = weakref(target)
			$CharacterAnimation.face_towards(target.global_position)
func _hit() -> void:
	if not alive or pending_target == null or not clock.running: return
	var target = pending_target.get_ref()
	pending_target = null
	if not is_instance_valid(target) or target.health <= 0: return
	acquire_blocker()
	if is_instance_valid(blocker) and target != blocker: return
	if target != blocker and global_position.distance_to(target.global_position) > stats.attack_range: return
	$SiegeImpact.global_position = target.global_position + Vector3.UP * 0.6
	$SiegeImpact.play()
	target.take_damage(stats.damage)
func take_damage(amount: int) -> void:
	if amount <= 0: return
	super.take_damage(maxi(1, amount - int(stats.armor)))

func choose_tower(radius: float) -> Node3D:
	var best: Node3D
	var best_score: float = -INF
	for tower in get_tree().get_nodes_in_group("placed_towers"):
		if tower.health <= 0 or tower.is_queued_for_deletion() or tower.resources == resources: continue
		var distance: float = global_position.distance_to(tower.global_position)
		if distance > radius: continue
		var score: float = -distance
		match targeting_priority:
			1: score = (10000.0 if tower.kind == "economy" else 0.0) - distance
			2: score = tower.health * 100.0 - distance
			3: score = -tower.health * 100.0 - distance
		if score > best_score:
			best = tower
			best_score = score
	return best

func fire_siege() -> bool:
	if role != "siege" or not alive or clock == null or not clock.running or get_tree().paused: return false
	if siege_remaining > 0.0 or shared_remaining > 0.0: return false
	acquire_blocker()
	# A guard engaging Matthew prevents bombardment, giving the defender a counter.
	if is_instance_valid(blocker) and blocker.health > 0: return false
	var target: Node3D = choose_tower(BALANCE.siege_range)
	if not is_instance_valid(target): return false
	siege_remaining = BALANCE.siege_cooldown
	for ally in get_tree().get_nodes_in_group("attacker_troops"):
		if ally.resources == resources and ally.role == "siege": ally.shared_remaining = BALANCE.siege_shared_delay
	$CharacterAnimation.face_towards(target.global_position)
	$CharacterAnimation.play_action(0.7)
	pending_target = null
	$SiegeImpact.global_position = target.global_position + Vector3.UP * 0.6
	$SiegeImpact.play()
	var start: Vector3 = global_position + Vector3.UP * 0.6
	var end: Vector3 = target.global_position + Vector3.UP * 0.6
	$SiegeTracer.global_position = (start + end) * 0.5
	if start.distance_to(end) > 0.01: $SiegeTracer.look_at(end, Vector3.UP)
	$SiegeTracer.scale = Vector3(1, 1, maxf(0.01, start.distance_to(end)))
	tracer_remaining = 0.25
	$SiegeTracer.show()
	target.take_damage(BALANCE.siege_damage)
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	if experience: experience.notice("MATTHEW | Backline bombardment")
	return true

func set_selected(value: bool) -> void:
	$TroopSelection/RangeCircle.visible = value
	$TroopSelection/RangeCircle.scale = Vector3.ONE * (BALANCE.siege_range if role == "siege" else 0.6)
func can_be_blocked() -> bool:
	return phase_remaining <= 0.0

func _reserve_post() -> void:
	if role != "economy" or not stats.get("stationary_economy", false): return
	var occupied_slots: Array[int] = []
	for ally in get_tree().get_nodes_in_group("attacker_troops"):
		if ally != self and ally.alive and ally.resources == resources and ally.post_reserved: occupied_slots.append(ally.post_slot)
	for slot in BALANCE.trading_post_limit:
		if not occupied_slots.has(slot):
			post_slot = slot
			break
	if post_slot < 0: return
	var path: Path3D = get_parent() as Path3D
	if path == null or path.curve == null: return
	var first: float = INF
	for pad in get_tree().get_nodes_in_group("tower_placement_pads"):
		first = minf(first, path.curve.get_closest_offset(path.to_local(pad.global_position)))
	if not is_finite(first): return
	post_progress = clampf(first + post_slot * 0.65, 0.0, maxf(0.0, path.curve.get_baked_length() - 0.5))
	post_reserved = true