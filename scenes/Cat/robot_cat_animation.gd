extends Node3D

@export_category("Movement")
@export_range(0.05, 5.0, 0.05)
var walk_speed: float = 0.35

@export_range(0.1, 20.0, 0.1)
var rotation_speed: float = 4.0

@export_range(0.05, 2.0, 0.05)
var arrival_distance: float = 0.2


@export_category("Animation")
@export var animation_player: AnimationPlayer

@export var walk_animation: StringName = &"walk"

@export_range(0.1, 3.0, 0.05)
var animation_speed: float = 0.8


var patrol_container: Node3D
var patrol_points: Array[Marker3D] = []
var current_patrol_index: int = 0


func _ready() -> void:
	patrol_container = get_tree().current_scene.get_node_or_null(
		"RobotCatPatrol"
	)

	if patrol_container == null:
		push_error("RobotCatPatrol not found.")
		return

	for child in patrol_container.get_children():
		if child is Marker3D:
			patrol_points.append(child)

	print("Robot Cat found ", patrol_points.size(), " patrol points.")

	setup_animation()


func setup_animation() -> void:
	if animation_player == null:
		animation_player = find_child(
			"AnimationPlayer",
			true,
			false
		) as AnimationPlayer

	if animation_player == null:
		push_error("Robot Cat AnimationPlayer not found.")
		return

	animation_player.active = true
	animation_player.speed_scale = animation_speed

	if animation_player.has_animation(walk_animation):
		animation_player.play(walk_animation)
	else:
		push_error(
			"Walk animation not found: " + str(walk_animation)
		)

		print("Available animations:")

		for anim in animation_player.get_animation_list():
			print(" - ", anim)


func _process(delta: float) -> void:
	if patrol_points.is_empty():
		return

	var target := patrol_points[current_patrol_index]

	var direction := target.global_position - global_position

	# Keep the cat at the same height.
	direction.y = 0.0

	if direction.length() <= arrival_distance:
		current_patrol_index += 1

		if current_patrol_index >= patrol_points.size():
			current_patrol_index = 0

		return

	direction = direction.normalized()

	# Move cat.
	global_position += direction * walk_speed * delta

	# Rotate toward next patrol point.
	var target_rotation := atan2(
		direction.x,
		direction.z
	)

	rotation.y = lerp_angle(
		rotation.y,
		target_rotation,
		rotation_speed * delta
	)

	# Keep walk animation playing.
	if animation_player:
		animation_player.speed_scale = animation_speed

		if animation_player.has_animation(walk_animation):
			if animation_player.current_animation != walk_animation:
				animation_player.play(walk_animation)


func set_walk_speed(new_speed: float) -> void:
	walk_speed = clampf(new_speed, 0.0, 5.0)


func set_animation_speed(new_speed: float) -> void:
	animation_speed = clampf(new_speed, 0.1, 3.0)

	if animation_player:
		animation_player.speed_scale = animation_speed
