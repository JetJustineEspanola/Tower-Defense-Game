extends "res://scripts/towers/combat_bug.gd"
var role: String = "objective"
var stats: Dictionary
var resources: PlayerResources
var siege_target: Node3D
var income_elapsed: float = 0.0
var cruise_speed: float
func _ready() -> void:
	maximum_health = stats.health
	speed = stats.speed
	cruise_speed = speed
	super._ready()
	$AttackTimer.wait_time = stats.interval
	add_to_group("attacker_troops")
func _physics_process(delta: float) -> void:
	if not alive or clock == null or not clock.running:
		super._physics_process(delta)
		return
	speed = cruise_speed
	siege_target = null
	if role == "siege" and not is_instance_valid(blocker):
		var nearest: float = stats.attack_range
		for tower in get_tree().get_nodes_in_group("placed_towers"):
			if tower.health <= 0 or tower.is_queued_for_deletion(): continue
			var distance: float = global_position.distance_to(tower.global_position)
			if distance < nearest:
				nearest = distance
				siege_target = tower
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
		if leader_progress >= 0.0 and progress >= maxf(0.0, leader_progress - 1.0):
			speed = 0.0
	super._physics_process(delta)
	if alive and is_instance_valid(siege_target):
		$CharacterAnimation.face_towards(siege_target.global_position)
func _attack() -> void:
	if role != "siege" or not alive or clock == null or not clock.running: return
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
	if target != blocker and global_position.distance_to(target.global_position) > stats.attack_range: return
	$SiegeImpact.global_position = target.global_position + Vector3.UP * 0.6
	$SiegeImpact.play()
	target.take_damage(stats.damage)
func take_damage(amount: int) -> void:
	if amount <= 0: return
	super.take_damage(maxi(1, amount - int(stats.armor)))
