extends Node3D
var selected_troop: Node3D
@onready var clock = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")
@onready var panel = $UI/Panel
@onready var content = $UI/Panel/Margin/Content
func _ready() -> void:
	content.get_node("Close").pressed.connect(clear_selection)
	content.get_node("Priority").item_selected.connect(_priority)
	content.get_node("Auto").toggled.connect(_auto)
	content.get_node("Ability").pressed.connect(_ability)
func _priority(index: int) -> void:
	if _can_order() and selected_troop.role == "siege": selected_troop.targeting_priority = index
func _auto(value: bool) -> void:
	if _can_order(): selected_troop.auto_siege = value
func _ability() -> void:
	if _can_order(): selected_troop.fire_siege()
func _can_order() -> bool:
	return is_instance_valid(selected_troop) and selected_troop.alive and clock.running and not get_tree().paused
func _process(_delta: float) -> void:
	if not is_instance_valid(selected_troop) or not selected_troop.alive or not clock.running:
		clear_selection()
		return
	var troop = selected_troop
	content.get_node("Health").text = "Health: %d / %d" % [troop.health, troop.maximum_health]
	var siege: bool = troop.role == "siege"
	content.get_node("Priority").visible = siege
	content.get_node("Auto").visible = siege
	content.get_node("Ability").visible = siege
	if siege:
		var remaining: float = maxf(troop.siege_remaining, troop.shared_remaining)
		var blocked: bool = is_instance_valid(troop.blocker) and troop.blocker.health > 0
		var target: bool = is_instance_valid(troop.choose_tower(troop.BALANCE.siege_range))
		content.get_node("Ability").disabled = remaining > 0.0 or blocked or not target or get_tree().paused
		content.get_node("Ability").text = "Blocked by guard" if blocked else ("Bombardment: %.0fs" % ceilf(remaining) if remaining > 0.0 else ("Fire bombardment" if target else "No tower in siege range"))
func select_troop(troop: Node3D) -> void:
	if get_tree().paused or not clock.running or not troop.alive: return
	if troop.resources != get_parent().resources: return
	clear_selection()
	selected_troop = troop
	troop.set_selected(true)
	panel.show()
	get_parent().get_node("AttackerUI/UpgradeSidebar").close()
	var names := {"siege": "MATTHEW", "objective": "RONEL", "economy": "CANGUIT"}
	content.get_node("Title").text = names[troop.role]
	content.get_node("Priority").select(troop.targeting_priority)
	content.get_node("Auto").set_pressed_no_signal(troop.auto_siege)
	match troop.role:
		"siege": content.get_node("Description").text = "Bombardment: %d damage / %.0fs.\nRange: %.0f | Shared delay: %.0fs\nCannot fire while blocked by a guard." % [troop.BALANCE.siege_damage, troop.BALANCE.siege_cooldown, troop.BALANCE.siege_range, troop.BALANCE.siege_shared_delay]
		"objective": content.get_node("Description").text = "Target: Enemy base\nDisruption: enemy economy income is %.0f%% slower while Ronel is alive. Does not stack." % (troop.BALANCE.disruption_fraction * 100)
		"economy": content.get_node("Description").text = "Order: Follow allies\nGenerates gold while alive. Cannot attack towers."
func clear_selection() -> void:
	if is_instance_valid(selected_troop): selected_troop.set_selected(false)
	selected_troop = null
	panel.hide()
func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused or not clock.running: return
	if event.is_action_pressed("ui_cancel"):
		clear_selection()
		return
	var position: Vector2
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			clear_selection()
			return
		if event.button_index != MOUSE_BUTTON_LEFT: return
		position = event.position
	elif event is InputEventScreenTouch and event.pressed: position = event.position
	else: return
	var camera := get_viewport().get_camera_3d()
	if camera == null: return
	var origin: Vector3 = camera.project_ray_origin(position)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + camera.project_ray_normal(position) * 500, 32)
	query.collide_with_areas = true
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		clear_selection()
		return
	var troop = hit.collider.get_parent().get_parent()
	if troop.is_in_group("attacker_troops"):
		select_troop(troop)
		get_viewport().set_input_as_handled()