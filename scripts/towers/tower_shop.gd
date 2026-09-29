extends CanvasLayer

@export var costs: Array[int] = [80, 100, 120]
@export var tower_scenes: Array[PackedScene] = [
	preload("res://scenes/towers/economy_tower.tscn"),
	preload("res://scenes/towers/attack_tower.tscn"),
	preload("res://scenes/towers/defense_tower.tscn")]
const NAMES: Array[String] = ["Economy", "Attack", "Defense"]
var selected_pad: TowerPlacementPad
var purchasing: bool = false
@onready var hud = get_node("../ResourceHUD/ArcaneQuestionTest")
var resources: PlayerResources
@onready var buttons: Array[Button] = [%Economy, %Attack, %Defense]

func _ready() -> void:
	if not hud.is_node_ready():
		await hud.ready
	resources = hud.resources
	$UpgradeSidebar.setup(hud)
	hud.answer_submitted.connect(_astral_reward)
	for pad in get_tree().get_nodes_in_group("tower_placement_pads"):
		pad.selected.connect(open_for_pad)
	resources.changed.connect(_refresh)
	hud.get_node("MatchClock").expired.connect(_close)

func open_for_pad(pad: TowerPlacementPad) -> void:
	if get_tree().paused or not hud.get_node("MatchClock").running:
		return
	if pad.occupied and is_instance_valid(pad.tower):
		_select_tower(pad.tower)
		return
	$UpgradeSidebar.close()
	selected_pad = pad
	%Picker.show()
	%Title.text = "DEPLOY STARTER TOWER"
	_refresh(resources.gold, resources.mana)

func _refresh(gold: int, _mana: int) -> void:
	var occupied: bool = is_instance_valid(selected_pad) and selected_pad.occupied
	%Balance.text = "Gold: %d" % gold
	%Status.text = "This pad already has a tower." if occupied else "Choose a starter tower. Buying uses gold immediately."
	for i in buttons.size():
		buttons[i].get_node("Content/Cost").text = "%d Gold" % costs[i]
		buttons[i].disabled = occupied or gold < costs[i]
		buttons[i].get_node("Content").modulate = Color(0.55, 0.6, 0.68) if buttons[i].disabled else Color.WHITE
		buttons[i].tooltip_text = "Need %d more gold" % maxi(0, costs[i] - gold) if gold < costs[i] else "Place this tower"

func _buy(index: int) -> void:
	if purchasing or get_tree().paused or not %Picker.visible or not hud.get_node("MatchClock").running:
		return
	if index < 0 or index >= costs.size() or index >= tower_scenes.size():
		return
	if not is_instance_valid(selected_pad) or selected_pad.occupied or costs[index] < 0:
		return
	if resources.gold < costs[index] or tower_scenes[index] == null:
		return
	var tower := tower_scenes[index].instantiate() as Node3D
	if tower == null:
		return
	purchasing = true
	# Reserve before spending emits signals, preventing a duplicate transaction.
	selected_pad.occupied = true
	if not resources.spend_gold(costs[index]):
		selected_pad.occupied = false
		tower.free()
		purchasing = false
		return
	tower.resources = resources
	tower.route = get_node("../EnemyPath")
	tower.clock = hud.get_node("MatchClock")
	tower.placement_pad = selected_pad
	selected_pad.tower = tower
	tower.selected.connect(_select_tower)
	selected_pad.get_parent().add_child(tower)
	tower.position = Vector3.ZERO
	purchasing = false
	_close()

func _close() -> void:
	%Picker.hide()
	selected_pad = null

func _send_practice_bug() -> void:
	get_node("../CombatReview").spawn_bug()

func _select_tower(tower: Node3D) -> void:
	if get_tree().paused or not hud.get_node("MatchClock").running: return
	_close()
	$UpgradeSidebar.open(tower)

func _astral_reward(correct: bool) -> void:
	if not correct or not hud.get_node("MatchClock").running: return
	var bonus: int = 0
	var source: Node3D
	for tower in get_tree().get_nodes_in_group("placed_towers"):
		if tower.health > 0 and tower.question_bonus > bonus:
			bonus = tower.question_bonus
			source = tower
	if bonus > 0:
		resources.add_gold(bonus)
		source.get_node("Effect").play(bonus)
		hud.get_node("%ResultLabel").text += " +%d Astral bonus!" % bonus

func _input(event: InputEvent) -> void:
	if %Picker.visible and event.is_action_pressed("ui_cancel"):
		_close()
		get_viewport().set_input_as_handled()
