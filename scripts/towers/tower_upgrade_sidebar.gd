extends Control
var tower: Node3D
var hud: Control
var resources: PlayerResources
var question_was_visible: bool = false
var active: bool = false
@onready var panel: PanelContainer = $Panel
@onready var rows: Array[Button] = [
	$Panel/Content/Scroll/Choices/Upgrade1, $Panel/Content/Scroll/Choices/Upgrade2,
	$Panel/Content/Scroll/Choices/Upgrade3, $Panel/Content/Scroll/Choices/Upgrade4,
	$Panel/Content/Scroll/Choices/Upgrade5]
func setup(resource_hud: Control) -> void:
	$Panel/Content/Targeting/Priority.item_selected.connect(_priority_selected)
	hud = resource_hud
	resources = hud.resources
	resources.changed.connect(_resources_changed)
	hud.get_node("MatchClock").expired.connect(close)
	for i in rows.size():
		rows[i].pressed.connect(_buy.bind(i))
func open(selected: Node3D) -> void:
	if get_tree().paused or not hud.get_node("MatchClock").running: return
	if active: _detach()
	else: question_was_visible = hud.get_node("%QuestionPanel").visible
	active = true
	tower = selected
	tower.set_selected(true)
	tower.upgraded.connect(refresh)
	tower.tree_exiting.connect(close)
	hud.get_node("%QuestionPanel").hide()
	hud.get_node("%QuestionToggle").hide()
	panel.show()
	refresh()
func _detach() -> void:
	if is_instance_valid(tower):
		tower.set_selected(false)
		if tower.upgraded.is_connected(refresh): tower.upgraded.disconnect(refresh)
		if tower.tree_exiting.is_connected(close): tower.tree_exiting.disconnect(close)
	tower = null
func close() -> void:
	if not active: return
	_detach()
	active = false
	panel.hide()
	hud.get_node("%QuestionPanel").visible = question_was_visible
	hud.get_node("%QuestionToggle").show()
func _resources_changed(_gold: int, _mana: int) -> void:
	if active: refresh()
func refresh() -> void:
	if not is_instance_valid(tower) or tower.upgrade_path == null:
		close()
		return
	var path: TowerUpgradePath = tower.upgrade_path
	var targeting: bool = tower.has_method("supports_targeting") and tower.supports_targeting()
	$Panel/Content/Targeting.visible = targeting
	if targeting:
		$Panel/Content/Targeting/Priority.select(tower.targeting_priority)
		$Panel/Content/Targeting/Priority.tooltip_text = ["Nearest to the base along the path.", "Furthest from the base along the path.", "Highest current health.", "Lowest current health.", "Nearest to the attacking unit."][tower.targeting_priority]
	$Panel/Content/Header/Name.text = path.character_name + " • " + path.role
	$Panel/Content/Portrait.texture = path.portrait
	$Panel/Content/Stats.text = tower.get_stats_text()
	$Panel/Content/Slots.text = "%d / %d abilities chosen • Gold: %d" % [tower.purchased.size(), path.choice_limit, resources.gold]
	for i in rows.size():
		rows[i].visible = i < path.choices.size()
		if i >= path.choices.size(): continue
		var choice: TowerUpgrade = path.choices[i]
		if choice == null:
			rows[i].hide()
			continue
		var price: int = tower.get_upgrade_cost(i) if tower.has_method("get_upgrade_cost") else choice.cost
		var state: String = "%d Gold" % price
		if price < choice.cost: state += " • First upgrade discount"
		if tower.purchased.has(choice.id): state = "OWNED"
		elif tower.purchased.size() >= path.choice_limit: state = "LOCKED"
		elif resources.gold < price: state = "Need %d more gold" % (price - resources.gold)
		rows[i].get_node("Content/Icon").texture = choice.icon
		rows[i].get_node("Content/Text/Title").text = choice.title
		rows[i].get_node("Content/Text/Description").text = choice.short_description if not choice.short_description.is_empty() else choice.description
		rows[i].get_node("Content/Text/Cost").text = state
		rows[i].tooltip_text = choice.description
		rows[i].disabled = not tower.can_buy_upgrade(i)
		var owned: bool = tower.purchased.has(choice.id)
		rows[i].get_node("Content").modulate = Color(0.62, 0.68, 0.76) if rows[i].disabled and not owned else Color.WHITE
		rows[i].get_node("Content/Text/Cost").modulate = Color(0.45, 1.0, 0.7) if owned else Color.WHITE
func _buy(index: int) -> void:
	var online = get_tree().current_scene
	if online != null and online.has_method("online_action"):
		if not is_instance_valid(tower): return
		if tower.is_in_group("placed_towers"): online.online_action("tower_upgrade", {"id": online.online_id(tower), "index": index})
		else: online.online_action("troop_upgrade", {"index": online.rosters.find(tower), "upgrade": index})
		return

	if is_instance_valid(tower):
		tower.buy_upgrade(index)
		refresh()

func _priority_selected(index: int) -> void:
	var online = get_tree().current_scene
	if online != null and online.has_method("online_action"):
		if is_instance_valid(tower): online.online_action("tower_priority", {"id": online.online_id(tower), "index": index})
		return

	if is_instance_valid(tower) and tower.has_method("set_targeting_priority"):
		tower.set_targeting_priority(index)
func _input(event: InputEvent) -> void:
	if active and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
