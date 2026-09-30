extends Node3D
signal selected(tower: Node3D)
signal upgraded
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
const TARGET_PRIORITY = preload("res://scripts/towers/target_priority.gd")
@export_enum("First", "Last", "Strongest", "Weakest", "Closest") var targeting_priority: int = 0

func supports_targeting() -> bool:
	return kind != "economy"

func set_targeting_priority(value: int) -> void:
	if value < 0 or value > 4 or not supports_targeting(): return
	if get_tree().paused or clock == null or not clock.running or health <= 0: return
	targeting_priority = value
	upgraded.emit()

func choose_attack_target() -> Node3D:
	var candidates: Array = []
	for enemy in get_tree().get_nodes_in_group("combat_bugs"):
		if is_instance_valid(enemy) and global_position.distance_to(enemy.global_position) <= attack_range:
			candidates.append(enemy)
	return TARGET_PRIORITY.select(candidates, global_position, targeting_priority)
@export var upgrade_path: TowerUpgradePath
@export var maximum_health: int = 100
@export var armor: int = 0
var health: int = 100
var purchased: Array[StringName] = []
var buying_upgrade: bool = false
var placement_pad: TowerPlacementPad
var guards: Array[Node3D] = []
var guard_count: int = 1
var guard_health: int = 60
var guard_damage: int = 10
var guard_capacity: int = 1
var extra_targets: int = 0
var secondary_damage_fraction: float = 0.5
var burn_damage: int = 0
var burn_seconds: float = 0.0
var bounty_gold: int = 0
var question_bonus: int = 0
@export_enum("economy", "attack", "defense") var kind: String = "attack"
@export var interval: float = 1.0
@export var income: int = 10
@export var damage: int = 20
@export var attack_range: float = 2.5
@export var defender_scene: PackedScene = preload("res://scenes/towers/defender.tscn")
var resources: PlayerResources
var route: Path3D
var clock: Node
var defender: Node3D
var beam_time: float = 0.0
var pending_target: WeakRef
var facing_target: WeakRef
var original_damage: int
var original_interval: float
var overcharge_remaining: float = 0.0
var overcharge_multiplier: float = 1.5

func effective_interval() -> float:
	var slowdown: float = 1.0
	if kind == "economy" and BALANCE.disrupted(get_tree(), resources): slowdown = 1.0 / (1.0 - BALANCE.disruption_fraction)
	return interval * slowdown / (overcharge_multiplier if overcharge_remaining > 0.0 else 1.0)
func _ready() -> void:
	original_damage = damage
	if kind == "economy": interval = BALANCE.economy_interval
	original_interval = interval
	add_to_group("placed_towers")
	health = maximum_health
	$Selection/PickArea.input_event.connect(_on_selected)
	set_selected(false)
	$CharacterAnimation.clock = clock
	$CharacterAnimation.impact.connect(_apply_hit)
	$ActionTimer.start(interval)
	_refresh_effects()
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	if experience: experience.call_deferred("celebrate", $Model)
func _process(delta: float) -> void:
	beam_time = maxf(0.0, beam_time - delta)
	$Beam.visible = beam_time > 0.0
	if clock == null or not clock.running:
		return
	if overcharge_remaining > 0.0:
		overcharge_remaining = maxf(0.0, overcharge_remaining - delta)
	var desired_interval: float = effective_interval()
	if not is_equal_approx($ActionTimer.wait_time, desired_interval):
		var fraction: float = $ActionTimer.time_left / $ActionTimer.wait_time
		$ActionTimer.start(maxf(0.001, desired_interval * fraction))
		$ActionTimer.wait_time = desired_interval
	if kind == "economy":
		$NameLabel.text = "ECONOMY | DISRUPTED -%.0f%%" % (BALANCE.disruption_fraction * 100) if BALANCE.disrupted(get_tree(), resources) else "ECONOMY"
	var target = facing_target.get_ref() if facing_target != null else null
	if is_instance_valid(target) and target.alive and global_position.distance_to(target.global_position) <= attack_range:
		$CharacterAnimation.face_towards(target.global_position)
	else:
		$CharacterAnimation.face_front()
func _act() -> void:
	if clock == null or not clock.running:
		return
	if kind == "economy":
		$CharacterAnimation.play_action(1.0)
		resources.add_gold(income)
		$Effect.play(income)
	elif kind == "defense":
		# Validate before a freed Object can be cast by a typed lambda.
		for i in range(guards.size() - 1, -1, -1):
			if not is_instance_valid(guards[i]):
				guards.remove_at(i)
			elif guards[i].is_queued_for_deletion() or guards[i].health <= 0:
				guards.remove_at(i)
		var spawned: int = 0
		while guards.size() < guard_count:
			var offset: float = route.curve.get_closest_offset(route.to_local(global_position))
			var base_offset: float = offset
			offset = clampf(offset + guards.size() * 0.7, 0.0, route.curve.get_baked_length())
			var rally: Vector3 = route.to_global(route.curve.sample_baked(offset))
			if Vector2(rally.x - global_position.x, rally.z - global_position.z).length() > attack_range:
				rally = route.to_global(route.curve.sample_baked(base_offset))
			if Vector2(rally.x - global_position.x, rally.z - global_position.z).length() > attack_range:
				break
			$CharacterAnimation.play_action(1.0)
			defender = defender_scene.instantiate()
			defender.clock = clock
			defender.maximum_health = guard_health
			defender.damage = guard_damage
			defender.block_capacity = guard_capacity
			add_child(defender)
			defender.global_position = global_position
			defender.walk_to(rally)
			guards.append(defender)
			spawned += 1
		if spawned > 0:
			$Effect.configure_summon(spawned)
			$Effect.play()
	else:
		var target: Node3D = choose_attack_target()
		if is_instance_valid(target):
			facing_target = weakref(target)
			if $CharacterAnimation.play_action(effective_interval() * 0.8):
				pending_target = weakref(target)
				$CharacterAnimation.face_towards(target.global_position)

func _apply_hit() -> void:
	if kind != "attack" or pending_target == null or not clock.running:
		return
	var target = pending_target.get_ref()
	pending_target = null
	if not is_instance_valid(target) or not target.alive:
		return
	if global_position.distance_to(target.global_position) > attack_range:
		return
	var start: Vector3 = global_position + Vector3.UP * 0.7
	var end: Vector3 = target.global_position + Vector3.UP * 0.3
	$Beam.global_position = (start + end) * 0.5
	$Beam.look_at(end, Vector3.UP)
	$Beam.scale = Vector3(1, 1, start.distance_to(end))
	beam_time = 0.0
	# Keep the slash horizontal, with its convex edge aimed at the enemy.
	var slash_target := Vector3(end.x, $Effect.global_position.y, end.z)
	if $Effect.global_position.distance_squared_to(slash_target) > 0.0001:
		$Effect.look_at(slash_target, Vector3.UP)
	$Effect.aim_attack(global_position.distance_to(target.global_position))
	$Effect.play()
	$HitEffect.global_position = end
	var victims: Array[Node3D] = [target]
	var forward: Vector3 = (target.global_position - global_position).normalized()
	for candidate in get_tree().get_nodes_in_group("combat_bugs"):
		if victims.size() >= extra_targets + 1: break
		if candidate == target or not candidate.alive: continue
		var direction: Vector3 = candidate.global_position - global_position
		if direction.length() <= attack_range and forward.dot(direction.normalized()) >= cos(deg_to_rad(35.0)):
			victims.append(candidate)
	for i in victims.size():
		var victim: Node3D = victims[i]
		if burn_damage > 0:
			victim.apply_burn(burn_damage, burn_seconds)
		var before: int = victim.health
		victim.take_damage(damage if i == 0 else maxi(1, roundi(damage * secondary_damage_fraction)))
		var experience = get_tree().current_scene.get_node_or_null("Experience")
		if experience: experience.record_damage(self, before - victim.health)

func _on_selected(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape: int) -> void:
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		selected.emit(self)

func set_selected(value: bool) -> void:
	$Selection/RangeCircle.visible = value
	$Selection/RangeCircle.scale = Vector3(attack_range, 1.0, attack_range)

func can_buy_upgrade(index: int) -> bool:
	if buying_upgrade or upgrade_path == null or resources == null or clock == null:
		return false
	if get_tree().paused or not clock.running or health <= 0:
		return false
	if index < 0 or index >= upgrade_path.choices.size() or purchased.size() >= upgrade_path.choice_limit:
		return false
	var choice: TowerUpgrade = upgrade_path.choices[index]
	return choice != null and not choice.id.is_empty() and not purchased.has(choice.id) and choice.cost >= 0 and resources.gold >= choice.cost

func buy_upgrade(index: int) -> bool:
	if not can_buy_upgrade(index): return false
	var choice: TowerUpgrade = upgrade_path.choices[index]
	buying_upgrade = true
	# Reserve ownership before the resource change signal can refresh the UI.
	purchased.append(choice.id)
	if not resources.spend_gold(choice.cost):
		purchased.erase(choice.id)
		buying_upgrade = false
		return false
	damage += choice.damage_bonus
	income += choice.income_bonus
	attack_range += choice.range_bonus
	interval = maxf(0.1, interval * maxf(0.05, choice.interval_multiplier))
	$ActionTimer.start(effective_interval())
	extra_targets += choice.extra_targets
	secondary_damage_fraction = choice.secondary_damage_fraction if choice.extra_targets > 0 else secondary_damage_fraction
	burn_damage += choice.burn_damage
	burn_seconds = maxf(burn_seconds, choice.burn_seconds)
	guard_count += choice.guard_count_bonus
	guard_health += choice.guard_health_bonus
	guard_damage += choice.guard_damage_bonus
	guard_capacity += choice.guard_capacity_bonus
	bounty_gold += choice.bounty_gold
	question_bonus += choice.question_bonus
	maximum_health += choice.health_bonus
	health += choice.health_bonus
	armor += choice.armor_bonus
	for guard in guards:
		if not is_instance_valid(guard): continue
		guard.maximum_health += choice.guard_health_bonus
		guard.health += choice.guard_health_bonus
		guard.damage = guard_damage
		guard.block_capacity = guard_capacity
		guard._update()
	set_selected($Selection/RangeCircle.visible)
	buying_upgrade = false
	_refresh_effects()
	var experience = get_tree().current_scene.get_node_or_null("Experience")
	if experience: experience.celebrate($Model)
	upgraded.emit()
	return true

func _refresh_effects() -> void:
	if kind == "attack":
		$Effect.configure_attack(float(damage) / maxi(1, original_damage), extra_targets, burn_damage > 0, interval / maxf(0.1, original_interval))

func take_damage(amount: int) -> void:
	if health <= 0 or amount <= 0: return
	var health_before: int = health
	health = maxi(0, health - maxi(1, amount - armor))
	$HealthFeedback.hit(health_before, health)
	upgraded.emit()
	if health == 0:
		var experience = get_tree().current_scene.get_node_or_null("Experience")
		if experience: experience.towers_destroyed += 1
		if is_instance_valid(placement_pad):
			placement_pad.occupied = false
			placement_pad.tower = null
		queue_free()

func get_stats_text() -> String:
	var result: String = "Health: %d / %d   Armor: %d\n" % [health, maximum_health, armor]
	if kind == "attack":
		return result + "Damage: %d   Attack: %.2fs\nAttack range: %.1f" % [damage, interval, attack_range]
	if kind == "defense":
		return result + "Guards: %d   Summon: %.1fs\nGuard HP: %d   Damage: %d\nBlocks: %d each | Deployment radius: %.1f" % [guard_count, interval, guard_health, guard_damage, guard_capacity, attack_range]
	return result + "Income: +%d gold / %.1fs\nBounty: %d   Astral bonus: %d\nBounty radius: %.1f" % [income, interval, bounty_gold, question_bonus, attack_range]
