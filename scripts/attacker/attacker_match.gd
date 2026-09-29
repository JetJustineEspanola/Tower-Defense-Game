extends Node3D
@export var starting_gold: int = 300
@export var base_maximum_health: int = 100
@export var active_troop_limit: int = 60
@export var preset_pad_indices: Array[int] = [1, 3, 5]
@export var preset_towers: Array[PackedScene] = [
	preload("res://scenes/towers/attack_tower.tscn"),
	preload("res://scenes/towers/defense_tower.tscn"),
	preload("res://scenes/towers/attack_tower.tscn")]
var base_health: int
var ended: bool = false
var orders: Array[Dictionary] = [{}, {}, {}]
var rosters: Array[Node3D] = []
var cards: Array[Node] = []
@onready var hud = $Gameplay/ResourceHUD/ArcaneQuestionTest
@onready var route: Path3D = $Gameplay/EnemyPath
@onready var clock: MatchClock = hud.get_node("MatchClock")
@onready var resources: PlayerResources = hud.resources
@onready var sidebar = $AttackerUI/UpgradeSidebar
func _ready() -> void:
	base_health = base_maximum_health
	resources.gold = starting_gold
	resources.changed.emit(resources.gold, resources.mana)
	hud.get_node("TopBar/Row/Health").hide()
	hud.get_node("TopBar/Row/Brand/Tagline").text = "ATTACKER  /  BREAK THE BASE"
	hud.get_node("PauseOverlay").visibility_changed.connect(_pause_overlay_changed)
	sidebar.setup(hud)
	for troop_name in ["Ronel", "Matthew", "Canguit"]:
		var roster = get_node("Roster/" + troop_name)
		roster.setup(resources, clock)
		rosters.append(roster)
		var card = get_node("AttackerUI/TrainingBar/Row/" + troop_name)
		cards.append(card)
		var i: int = cards.size() - 1
		card.get_node("Content/Actions/Train").pressed.connect(train.bind(i))
		card.get_node("Content/Actions/Upgrade").pressed.connect(_open_upgrades.bind(i))
		card.get_node("Content/Header/Portrait").texture = roster.upgrade_path.portrait
		card.get_node("Content/Header/Text/Name").text = troop_name
		card.get_node("Content/Header/Text/Role").text = roster.upgrade_path.role
	clock.expired.connect(_timeout)
	_deploy_defenders()
	_update_base_label()
	_refresh_cards()
func _deploy_defenders() -> void:
	var pads = get_tree().get_nodes_in_group("tower_placement_pads")
	for pad in pads:
		pad.input_ray_pickable = false
	for i in mini(preset_pad_indices.size(), preset_towers.size()):
		var index: int = preset_pad_indices[i]
		if index < 0 or index >= pads.size(): continue
		var pad = pads[index]
		var tower = preset_towers[i].instantiate()
		tower.resources = $DefenderResources
		tower.clock = clock
		tower.route = route
		tower.placement_pad = pad
		pad.occupied = true
		pad.tower = tower
		pad.get_parent().add_child(tower)
		tower.position = Vector3.ZERO
		tower.get_node("Selection/PickArea").input_ray_pickable = false
func _process(delta: float) -> void:
	if ended or not clock.running: return
	for i in orders.size():
		if orders[i].is_empty(): continue
		orders[i].remaining = maxf(0.0, orders[i].remaining - delta)
		if orders[i].remaining <= 0.0:
			_spawn(i, orders[i].stats)
			orders[i] = {}
	_refresh_cards()
func train(index: int) -> void:
	if ended or get_tree().paused or not clock.running or index < 0 or index >= rosters.size(): return
	if not orders[index].is_empty(): return
	var reserved: int = get_tree().get_nodes_in_group("attacker_troops").size()
	for order in orders:
		if not order.is_empty(): reserved += 1
	if reserved >= active_troop_limit: return
	var roster = rosters[index]
	if resources.gold < roster.definition.cost: return
	var snapshot: Dictionary = roster.stats.duplicate(true)
	# Reserve before the wallet signal fires. New upgrades cannot alter this order.
	orders[index] = {"remaining": snapshot.training, "total": snapshot.training, "stats": snapshot}
	if not resources.spend_gold(roster.definition.cost): orders[index] = {}
	_refresh_cards()
func _spawn(index: int, snapshot: Dictionary) -> Node3D:
	var definition: TroopDefinition = rosters[index].definition
	var troop = definition.scene.instantiate()
	troop.stats = snapshot.duplicate(true)
	troop.role = definition.role
	troop.resources = resources
	troop.clock = clock
	troop.arrived.connect(_arrived.bind(int(snapshot.base_damage)))
	route.add_child(troop)
	return troop
func _arrived(damage: int) -> void:
	if ended or not clock.running: return
	base_health = maxi(0, base_health - damage)
	_update_base_label()
	if base_health == 0: _finish(true)
func _update_base_label() -> void:
	$Gameplay/AlliedBase/TargetHealth.text = "ENEMY BASE\n%d / %d" % [base_health, base_maximum_health]
func _refresh_cards() -> void:
	var reserved: int = get_tree().get_nodes_in_group("attacker_troops").size()
	for order in orders:
		if not order.is_empty(): reserved += 1
	var full: bool = reserved >= active_troop_limit
	for i in cards.size():
		var card = cards[i]
		var roster = rosters[i]
		var training: bool = not orders[i].is_empty()
		card.get_node("Content/Actions/Train").disabled = ended or training or full or resources.gold < roster.definition.cost
		card.get_node("Content/Actions/Train").text = "Train • %d Gold" % roster.definition.cost
		card.get_node("Content/Progress").value = 100.0 * (1.0 - orders[i].remaining / orders[i].total) if training else 0.0
		card.get_node("Content/Status").text = "Training %.1fs" % orders[i].remaining if training else "Ready • %.1fs training" % roster.stats.training
		card.get_node("Content/Actions/Upgrade").disabled = ended
func _open_upgrades(index: int) -> void:
	if not ended and not get_tree().paused: sidebar.open(rosters[index])
func _pause_overlay_changed() -> void:
	$AttackerUI.visible = not hud.get_node("PauseOverlay").visible
func _timeout() -> void:
	_finish(base_health <= 0)
func _finish(won: bool) -> void:
	if ended: return
	ended = true
	clock.running = false
	orders = [{}, {}, {}]
	sidebar.close()
	hud.get_node("Resources/ManaTimer").stop()
	$MatchResult.present(won, "attacker", clock, resources, base_health, base_maximum_health)
	_refresh_cards()
func _retry() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
func _menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/codeborn_menu.tscn")
