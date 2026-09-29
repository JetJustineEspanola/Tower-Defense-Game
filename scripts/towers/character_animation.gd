extends Node
## Owns playback only; actor scripts validate and apply the impact.
signal impact
@export var idle_clip: StringName
@export var action_clip: StringName
@export var walk_clip: StringName
@export var fixed_idle_facing: bool = false
@export var idle_yaw_degrees: float = -180.0
var moving: bool = false
@export var facing_offset: float = 0.0
@export_range(0.0, 1.0) var impact_fraction: float = 0.45
var player: AnimationPlayer
var clock: Node
var busy: bool = false
@onready var impact_timer: Timer = $ImpactTimer

func _ready() -> void:
	player = get_parent().get_node("Model").find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null:
		push_warning("Character has no AnimationPlayer: " + str(get_parent().name))
		return
	# Imported animations may be shared by several actors.
	for library_name in player.get_animation_library_list():
		var library: AnimationLibrary = player.get_animation_library(library_name).duplicate(true)
		player.remove_animation_library(library_name)
		player.add_animation_library(library_name, library)
	if player.has_animation(idle_clip):
		player.get_animation(idle_clip).loop_mode = Animation.LOOP_LINEAR
	if player.has_animation(action_clip):
		player.get_animation(action_clip).loop_mode = Animation.LOOP_NONE
	if player.has_animation(walk_clip):
		player.get_animation(walk_clip).loop_mode = Animation.LOOP_LINEAR
	player.animation_finished.connect(_finished)
	_idle()
	# Apply the first idle pose before the model's first rendered frame.
	player.play(idle_clip, 0.0)
	player.advance(0.0)
	call_deferred("face_front")

func play_action(duration: float = 0.8) -> bool:
	if busy or player == null or not player.has_animation(action_clip):
		return false
	if clock != null and not clock.running:
		return false
	busy = true
	duration = maxf(0.1, duration)
	player.speed_scale = player.get_animation(action_clip).length / duration
	player.play(action_clip, 0.08)
	impact_timer.start(duration * impact_fraction)
	return true

func _impact() -> void:
	if clock == null or clock.running:
		impact.emit()

func _finished(clip: StringName) -> void:
	if clip == action_clip:
		busy = false
		_idle()

func _idle() -> void:
	var clip: StringName = walk_clip if moving else idle_clip
	if player != null and player.has_animation(clip):
		player.speed_scale = 1.0
		player.play(clip, 0.1)
		if fixed_idle_facing:
			face_front()

func set_moving(value: bool) -> void:
	if moving == value:
		return
	moving = value
	if not busy:
		_idle()

func face_front() -> void:
	if fixed_idle_facing:
		get_parent().get_node("Model").rotation_degrees.y = idle_yaw_degrees

func face_towards(position: Vector3) -> void:
	var model: Node3D = get_parent().get_node("Model")
	var direction: Vector3 = position - get_parent().global_position
	if Vector2(direction.x, direction.z).length_squared() > 0.001:
		model.global_rotation.y = atan2(direction.x, direction.z) + facing_offset

func _process(_delta: float) -> void:
	if clock != null and not clock.running and player != null:
		impact_timer.stop()
		player.pause()
	elif player != null and not busy and not player.is_playing():
		_idle()
