extends Node3D

@onready var path3d: Path3D = $Path3D
@onready var move_button: Button = $CanvasLayer/VBoxContainer/MoveButton
@onready var reset_button: Button = $CanvasLayer/VBoxContainer/ResetButton

var target_dummy_scene: PackedScene = preload("res://scenes/tests/target_dummy.tscn")
var inside_range: bool = false

func _ready() -> void:
	# Make sure the cursor is free/visible so it can actually click the UI.
	# If a camera script elsewhere sets this to CAPTURED/HIDDEN for mouse-look,
	# it will swallow clicks before they ever reach the buttons.
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Force correct mouse filter in case something upstream changed it
	move_button.mouse_filter = Control.MOUSE_FILTER_STOP
	reset_button.mouse_filter = Control.MOUSE_FILTER_STOP
	$CanvasLayer/VBoxContainer.mouse_filter = Control.MOUSE_FILTER_PASS

	# Make sure CanvasLayer draws/handles input above the 3D world
	$CanvasLayer.layer = 10

	# Connect only if not already connected, avoids double-firing
	if not move_button.pressed.is_connected(_on_move_button_pressed):
		move_button.pressed.connect(_on_move_button_pressed)
	if not reset_button.pressed.is_connected(_on_reset_button_pressed):
		reset_button.pressed.connect(_on_reset_button_pressed)

	print("[TowerDamageTest] Buttons connected. Move=%s Reset=%s" % [
		move_button.pressed.is_connected(_on_move_button_pressed),
		reset_button.pressed.is_connected(_on_reset_button_pressed)
	])

func _on_move_button_pressed() -> void:
	print("[TowerDamageTest] Move button pressed. inside_range was: ", inside_range)

	var path_follow = _get_or_respawn_path_follow()
	if is_instance_valid(path_follow):
		if inside_range:
			path_follow.progress_ratio = 0.0 # Teleport back to start of path
			inside_range = false
		else:
			path_follow.progress_ratio = 0.3 # Teleport to 30% along the path (inside range)
			inside_range = true
		print("[TowerDamageTest] inside_range is now: ", inside_range)
	else:
		push_warning("[TowerDamageTest] path_follow invalid after respawn attempt")

func _on_reset_button_pressed() -> void:
	print("[TowerDamageTest] Reset button pressed.")
	get_tree().reload_current_scene()

# Restores the PathFollow3D and Dummy if they were deleted upon reaching 0 HP
func _get_or_respawn_path_follow() -> PathFollow3D:
	if path3d.has_node("PathFollow3D"):
		return path3d.get_node("PathFollow3D") as PathFollow3D

	print("[TowerDamageTest] Respawning PathFollow3D + TargetDummy")

	# Respawn PathFollow3D and TargetDummy if defeated
	var new_follow = PathFollow3D.new()
	new_follow.name = "PathFollow3D"
	new_follow.rotation_mode = PathFollow3D.ROTATION_Y
	new_follow.loop = false

	var new_dummy = target_dummy_scene.instantiate()
	new_follow.add_child(new_dummy)
	path3d.add_child(new_follow)

	return new_follow
