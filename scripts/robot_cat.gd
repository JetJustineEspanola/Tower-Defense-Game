extends Node3D


# =========================================================
# MOVEMENT
# =========================================================

@export_category("Movement")

@export_range(0.05, 5.0, 0.05)
var walk_speed: float = 0.4

# Lower = wider/slower turns
# Higher = sharper/faster turns
@export_range(0.1, 20.0, 0.1)
var rotation_speed: float = 2.0

@export_range(0.05, 2.0, 0.05)
var arrival_distance: float = 0.3


# =========================================================
# ANIMATION
# =========================================================

@export_category("Animation")

@export var animation_player: AnimationPlayer

@export var walk_animation: StringName = &"walk"

@export_range(0.1, 3.0, 0.05)
var animation_speed: float = 1.0


# =========================================================
# PATROL
# =========================================================

var patrol_container: Node3D
var patrol_points: Array[Marker3D] = []

var current_patrol_index: int = 0


func _ready() -> void:
	find_patrol_container()
	load_patrol_points()
	setup_animation()


# =========================================================
# PATROL SETUP
# =========================================================

func find_patrol_container() -> void:
	patrol_container = get_tree().current_scene.get_node_or_null(
		"RobotCatPatrol"
	)

	if patrol_container == null:
		push_error(
			"Robot Cat: Could not find RobotCatPatrol in the current scene."
		)


func load_patrol_points() -> void:
	patrol_points.clear()

	if patrol_container == null:
		return

	for child in patrol_container.get_children():
		if child is Marker3D:
			patrol_points.append(child)

	print(
		"Robot Cat found ",
		patrol_points.size(),
		" patrol points."
	)


# =========================================================
# ANIMATION
# =========================================================

func setup_animation() -> void:
	if animation_player == null:
		animation_player = find_child(
			"AnimationPlayer",
			true,
			false
		) as AnimationPlayer

	if animation_player == null:
		push_error(
			"Robot Cat: AnimationPlayer could not be found."
		)
		return

	animation_player.active = true
	animation_player.speed_scale = animation_speed

	print(
		"Robot Cat AnimationPlayer found: ",
		animation_player.name
	)

	print("Available robot cat animations:")

	for animation_name in animation_player.get_animation_list():
		print(" - ", animation_name)

	if animation_player.has_animation(walk_animation):
		animation_player.play(walk_animation)

		print(
			"Robot Cat playing animation: ",
			walk_animation
		)
	else:
		push_error(
			"Robot Cat: Animation not found: "
			+ str(walk_animation)
		)


# =========================================================
# MOVEMENT
# =========================================================

func _process(delta: float) -> void:
	if patrol_points.is_empty():
		return

	if current_patrol_index >= patrol_points.size():
		current_patrol_index = 0

	var target: Marker3D = patrol_points[current_patrol_index]

	if target == null:
		return

	var to_target: Vector3 = (
		target.global_position - global_position
	)

	# Keep cat at its current height.
	to_target.y = 0.0

	var distance: float = to_target.length()

	if distance <= arrival_distance:
		next_patrol_point()
		return

	var desired_direction: Vector3 = to_target.normalized()

	# Turn smoothly toward the patrol point.
	rotate_toward_direction(
		desired_direction,
		delta
	)

	# Move in the direction the cat is currently facing.
	# This makes the cat follow a curved path instead of sliding
	# directly toward the next marker.
	var forward: Vector3 = Vector3(
		sin(rotation.y),
		0.0,
		cos(rotation.y)
	)

	global_position += (
		forward
		* walk_speed
		* delta
	)

	ensure_walk_animation()


func next_patrol_point() -> void:
	current_patrol_index += 1

	if current_patrol_index >= patrol_points.size():
		current_patrol_index = 0


# =========================================================
# SMOOTH TURNING
# =========================================================

func rotate_toward_direction(
	direction: Vector3,
	delta: float
) -> void:

	if direction.length_squared() <= 0.001:
		return

	var target_rotation: float = atan2(
		direction.x,
		direction.z
	)

	# Frame-rate-independent smooth turning.
	var turn_weight: float = (
		1.0 - exp(-rotation_speed * delta)
	)

	rotation.y = lerp_angle(
		rotation.y,
		target_rotation,
		turn_weight
	)


# =========================================================
# WALK ANIMATION
# =========================================================

func ensure_walk_animation() -> void:
	if animation_player == null:
		return

	animation_player.speed_scale = animation_speed

	if not animation_player.has_animation(walk_animation):
		return

	if animation_player.current_animation != walk_animation:
		animation_player.play(walk_animation)


# =========================================================
# RUNTIME SPEED CONTROLS
# =========================================================

func set_walk_speed(new_speed: float) -> void:
	walk_speed = clampf(
		new_speed,
		0.0,
		5.0
	)


func set_animation_speed(new_speed: float) -> void:
	animation_speed = clampf(
		new_speed,
		0.1,
		3.0
	)

	if animation_player:
		animation_player.speed_scale = animation_speed


func set_rotation_speed(new_speed: float) -> void:
	rotation_speed = clampf(
		new_speed,
		0.1,
		20.0
	)
