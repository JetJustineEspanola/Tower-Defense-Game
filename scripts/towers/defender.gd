extends Node3D
@export var maximum_health: int = 60
@export var damage: int = 10
var health: int = 60
var enemy: Node3D
var clock: Node
var pending_target: WeakRef
@export var movement_speed: float = 1.2
var rally_position: Vector3
var travelling: bool = false
var block_capacity: int = 1

func walk_to(destination: Vector3) -> void:
	_release_enemies()
	rally_position = destination
	travelling = true
	$CharacterAnimation.set_moving(true)

func _physics_process(delta: float) -> void:
	if health <= 0 or clock == null or not clock.running:
		return
	if not travelling:
		var locked: bool = false
		for bug in get_tree().get_nodes_in_group("combat_bugs"):
			if bug.alive and bug.blocker == self: locked = true
		if locked: return
		var target: Node3D = null
		var nearest: float = INF
		for bug in get_tree().get_nodes_in_group("combat_bugs"):
			if not bug.alive or not bug.can_be_blocked() or is_instance_valid(bug.blocker): continue
			if get_parent().global_position.distance_to(bug.global_position) > get_parent().attack_range: continue
			# Intercept threats in the tower's patrol radius, including ranged siege.
			var distance: float = global_position.distance_to(bug.global_position)
			if distance < nearest:
				target = bug
				nearest = distance
		if target != null:
			if nearest <= 0.55:
				target.blocker = self
				enemy = target
				$CharacterAnimation.set_moving(false)
				return
			_move_towards(target.global_position, delta)
			return
		if global_position.distance_to(rally_position) > 0.05:
			_move_towards(rally_position, delta)
		else: $CharacterAnimation.set_moving(false)
		return
	_move_towards(rally_position, delta)
	if global_position.distance_to(rally_position) < 0.01:
		travelling = false
		$CharacterAnimation.set_moving(false)

func _move_towards(destination: Vector3, delta: float) -> void:
	$CharacterAnimation.set_moving(true)
	$CharacterAnimation.face_towards(destination)
	global_position = global_position.move_toward(destination, movement_speed * delta)

func _release_enemies() -> void:
	pending_target = null
	enemy = null
	for bug in get_tree().get_nodes_in_group("combat_bugs"):
		if bug.blocker == self: bug.blocker = null

func set_selected(value: bool) -> void:
	$GuardSelection/RangeCircle.visible = value

func _exit_tree() -> void:
	_release_enemies()
func _ready() -> void:
	$CharacterAnimation.clock = clock
	$CharacterAnimation.impact.connect(_hit)
	health = maximum_health
	_update()
func available() -> bool:
	if travelling or health <= 0 or is_queued_for_deletion(): return false
	var count: int = 0
	for bug in get_tree().get_nodes_in_group("combat_bugs"):
		if bug.alive and bug.blocker == self: count += 1
	return count < block_capacity
func take_damage(amount: int) -> void:
	if health <= 0: return
	var health_before: int = health
	health = maxi(0, health - amount)
	$HealthFeedback.hit(health_before, health)
	_update()
	if health == 0: queue_free()
func _attack() -> void:
	if clock == null or not clock.running: return
	var candidates: Array = []
	for bug in get_tree().get_nodes_in_group("combat_bugs"):
		if bug.alive and bug.blocker == self:
			candidates.append(bug)
	var mode: int = get_parent().targeting_priority if get_parent().has_method("supports_targeting") else 0
	enemy = preload("res://scripts/towers/target_priority.gd").select(candidates, global_position, mode)
	if is_instance_valid(enemy) and enemy.alive:
		if $CharacterAnimation.play_action(0.8):
			pending_target = weakref(enemy)
			$CharacterAnimation.face_towards(enemy.global_position)
	else:
		enemy = null
func _hit() -> void:
	if pending_target == null or not clock.running: return
	var target = pending_target.get_ref()
	pending_target = null
	if is_instance_valid(target) and target.alive and target.blocker == self:
		var before: int = target.health
		target.take_damage(damage)
		var experience = get_tree().current_scene.get_node_or_null("Experience")
		if experience: experience.record_damage(get_parent(), before - target.health)
func _update() -> void:
	$Health.text = "GUARD %d" % health

