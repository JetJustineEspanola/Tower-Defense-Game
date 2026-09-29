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
	rally_position = destination
	travelling = true
	$CharacterAnimation.set_moving(true)

func _physics_process(delta: float) -> void:
	if not travelling or clock == null or not clock.running:
		return
	$CharacterAnimation.face_towards(rally_position)
	global_position = global_position.move_toward(rally_position, movement_speed * delta)
	if global_position.distance_to(rally_position) < 0.01:
		travelling = false
		$CharacterAnimation.set_moving(false)
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
	health = maxi(0, health - amount)
	_update()
	if health == 0: queue_free()
func _attack() -> void:
	if clock == null or not clock.running: return
	enemy = null
	for bug in get_tree().get_nodes_in_group("combat_bugs"):
		if bug.alive and bug.blocker == self:
			enemy = bug
			break
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
		target.take_damage(damage)
func _update() -> void:
	$Health.text = "GUARD %d" % health
