extends PathFollow3D
signal arrived
@export var speed: float = 0.8
@export var maximum_health: int = 60
var health: int = 60
var alive: bool = true
var blocker: Node3D
var clock: Node
var pending_target: WeakRef
var burn_remaining: float = 0.0
var burn_tick: float = 0.0
var burn_amount: int = 0

func apply_burn(amount: int, seconds: float) -> void:
	if burn_remaining <= 0.0: burn_tick = 0.0
	burn_amount = maxi(burn_amount, amount)
	burn_remaining = maxf(burn_remaining, seconds)
	$BurningEmbers.emitting = burn_remaining > 0.0
func _ready() -> void:
	$CharacterAnimation.clock = clock
	$CharacterAnimation.impact.connect(_hit)
	health = maximum_health
	_update()
func _physics_process(delta: float) -> void:
	if not alive or clock == null or not clock.running:
		$BurningEmbers.emitting = false
		return
	if burn_remaining > 0.0:
		var elapsed: float = minf(delta, burn_remaining)
		burn_remaining = maxf(0.0, burn_remaining - delta)
		$BurningEmbers.emitting = burn_remaining > 0.0
		burn_tick += elapsed
		while burn_tick >= 0.999:
			burn_tick -= 1.0
			take_damage(burn_amount)
			if not alive: return
	acquire_blocker()
	if is_instance_valid(blocker):
		$CharacterAnimation.set_moving(false)
		return
	$CharacterAnimation.set_moving(speed > 0.0)
	$Model.rotation.y = 0.0
	progress += speed * delta
	if progress_ratio >= 1.0:
		_resolve()
		arrived.emit()
func _attack() -> void:
	if alive and clock != null and clock.running and is_instance_valid(blocker):
		if $CharacterAnimation.play_action(0.8):
			pending_target = weakref(blocker)
			$CharacterAnimation.face_towards(blocker.global_position)
func _hit() -> void:
	if not alive or pending_target == null or not clock.running: return
	var target = pending_target.get_ref()
	pending_target = null
	if is_instance_valid(target) and is_instance_valid(blocker) and target == blocker and target.health > 0:
		target.take_damage(15)
func take_damage(amount: int) -> void:
	if not alive or amount <= 0: return
	var health_before: int = health
	health = maxi(0, health - amount)
	$HealthFeedback.hit(health_before, health)
	_update()
	if health == 0:
		var experience = get_tree().current_scene.get_node_or_null("Experience")
		if experience: experience.bugs_defeated += 1
		var collector: Node3D
		var nearest: float = INF
		for tower in get_tree().get_nodes_in_group("placed_towers"):
			var distance: float = global_position.distance_to(tower.global_position)
			if tower.health > 0 and tower.bounty_gold > 0 and distance <= tower.attack_range and distance < nearest:
				collector = tower
				nearest = distance
		if is_instance_valid(collector):
			collector.resources.add_gold(collector.bounty_gold)
			collector.get_node("Effect").play(collector.bounty_gold)
		_resolve()
func _resolve() -> void:
	alive = false
	if is_instance_valid(blocker): blocker.enemy = null
	remove_from_group("combat_bugs")
	queue_free()
func _update() -> void:
	$Health.text = "%d / %d" % [health, maximum_health]


func can_be_blocked() -> bool:
	return true

func acquire_blocker() -> void:
	if not can_be_blocked():
		if is_instance_valid(blocker) and blocker.enemy == self: blocker.enemy = null
		blocker = null
		return
	if is_instance_valid(blocker) and blocker.health > 0 and not blocker.is_queued_for_deletion(): return
	blocker = null
	for guard in get_tree().get_nodes_in_group("defenders"):
		if guard.available() and global_position.distance_to(guard.global_position) < 0.65:
			blocker = guard
			guard.enemy = self
			return