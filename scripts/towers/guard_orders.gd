extends Node3D
## Map clicks reach this handler only after UI controls have handled their input.
var selected_guard: Node3D
@onready var clock: MatchClock = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")
@onready var route: Path3D = get_parent().get_node("Gameplay/EnemyPath")

func _process(_delta: float) -> void:
	if not is_instance_valid(selected_guard) or selected_guard.health <= 0 or not clock.running:
		clear_selection()

func _unhandled_input(event: InputEvent) -> void:
	if get_parent().has_node("Roster") or get_tree().paused or not clock.running: return
	if event.is_action_pressed("ui_cancel") and is_instance_valid(selected_guard):
		clear_selection()
		get_viewport().set_input_as_handled()
		return
	if not event is InputEventMouseButton or not event.pressed: return
	if event.button_index == MOUSE_BUTTON_RIGHT:
		clear_selection()
		return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	var camera := get_viewport().get_camera_3d()
	if camera == null: return
	var origin: Vector3 = camera.project_ray_origin(event.position)
	var direction: Vector3 = camera.project_ray_normal(event.position)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 500.0, 16)
	query.collide_with_areas = true
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var guard = hit.collider.get_parent().get_parent()
		if guard.is_in_group("defenders"):
			select_guard(guard)
			get_viewport().set_input_as_handled()
			return
	if not is_instance_valid(selected_guard): return
	var point = Plane(Vector3.UP, selected_guard.rally_position.y).intersects_ray(origin, direction)
	if point != null: order_to(point)
	get_viewport().set_input_as_handled()

func select_guard(guard: Node3D) -> void:
	clear_selection()
	selected_guard = guard
	var shop = get_parent().get_node("Gameplay/TowerShop")
	shop._close()
	shop.get_node("UpgradeSidebar").close()
	guard.set_selected(true)
	guard.get_parent().set_selected(true)
	get_parent().get_node("Experience").notice("SMALL ARJIE • Click the path inside the white circle. Right-click cancels.")

func order_to(point: Vector3) -> bool:
	if not is_instance_valid(selected_guard) or get_tree().paused or not clock.running: return false
	var offset: float = route.curve.get_closest_offset(route.to_local(point))
	var destination: Vector3 = route.to_global(route.curve.sample_baked(offset))
	var tower = selected_guard.get_parent()
	if Vector2(point.x - destination.x, point.z - destination.z).length() > 1.0 or tower.global_position.distance_to(destination) > tower.attack_range:
		get_parent().get_node("Experience").notice("Choose a path position inside Arjie's white range circle.")
		return false
	selected_guard.walk_to(destination)
	$Destination.global_position = destination + Vector3.UP * 0.07
	$Destination.show()
	get_parent().get_node("Experience").notice("Small Arjie is moving to the new rally point.")
	return true

func clear_selection() -> void:
	if is_instance_valid(selected_guard):
		selected_guard.set_selected(false)
		if is_instance_valid(selected_guard.get_parent()): selected_guard.get_parent().set_selected(false)
	selected_guard = null
	$Destination.hide()
