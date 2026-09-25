extends Node3D

@export var damage: float = 10.0
@export var attack_interval: float = 1.0
@export var attack_range: float = 2.0
@export var rotation_speed: float = 10.0

var targets_in_range: Array[Node3D] = []
var current_target: Node3D = null

func _ready() -> void:
	$AttackTimer.wait_time = attack_interval
	$AttackRange.body_entered.connect(_on_body_entered)
	$AttackRange.body_exited.connect(_on_body_exited)
	$AttackTimer.timeout.connect(_on_timer_timeout)
	
	# Dynamically update sphere shape radius from exported variable
	if $AttackRange/RangeShape.shape is SphereShape3D:
		$AttackRange/RangeShape.shape.radius = attack_range

func _process(delta: float) -> void:
	_clean_target_list()
	_update_current_target()
	_track_and_follow_target(delta)

func _clean_target_list() -> void:
	targets_in_range = targets_in_range.filter(func(t): return is_instance_valid(t))

func _update_current_target() -> void:
	if targets_in_range.size() > 0:
		current_target = targets_in_range[0]
	else:
		current_target = null

func _track_and_follow_target(delta: float) -> void:
	if is_instance_valid(current_target):
		var target_pos = current_target.global_position
		target_pos.y = global_position.y
		
		if global_position.distance_squared_to(target_pos) > 0.001:
			var target_transform = transform.looking_at(target_pos, Vector3.UP)
			transform.basis = transform.basis.slerp(target_transform.basis, rotation_speed * delta)

func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		if not targets_in_range.has(body):
			targets_in_range.append(body)
		if $AttackTimer.is_stopped():
			$AttackTimer.start()

func _on_body_exited(body: Node3D) -> void:
	targets_in_range.erase(body)
	if targets_in_range.is_empty():
		$AttackTimer.stop()

func _on_timer_timeout() -> void:
	if is_instance_valid(current_target):
		current_target.take_damage(damage)
		# Check if target died after attack
		if not is_instance_valid(current_target):
			_clean_target_list()
			if targets_in_range.is_empty():
				$AttackTimer.stop()
	else:
		$AttackTimer.stop()
