extends Node
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
## Local defender AI. Purchases and upgrades use the same wallet and tower rules as the player.
@export_range(1, 60, 1) var opening_delay_seconds: float = 5.0
@export_range(1, 60, 1) var decision_interval_seconds: float = 8.0
@export_range(1, 20, 1) var maximum_towers: int = 6
@export var answer_questions: bool = true
@export_range(5, 120, 1) var question_interval_seconds: float = 20.0
@export_range(0, 1, 0.05) var question_accuracy: float = 0.75
@export var tower_scenes: Array[PackedScene] = [
	preload("res://scenes/towers/economy_tower.tscn"),
	preload("res://scenes/towers/attack_tower.tscn"),
	preload("res://scenes/towers/defense_tower.tscn")]
@export var tower_costs: Array[int] = [80, 100, 120]
var wait_remaining: float
var question_elapsed: float = 0.0
var mana_elapsed: float = 0.0
var decisions: int = 0
var questions_attempted: int = 0
var questions_correct: int = 0
var spent_gold: int = 0
var rng := RandomNumberGenerator.new()
var quiz = preload("res://scripts/questions/question_run.gd").new()
@onready var match_scene = get_parent()
@onready var wallet: PlayerResources = get_node("../DefenderResources")
@onready var route: Path3D = get_node("../Gameplay/EnemyPath")
@onready var clock: MatchClock = get_node("../Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")

func _ready() -> void:
	wait_remaining = opening_delay_seconds
	rng.randomize()
	quiz.setup(preload("res://scripts/questions/deck_store.gd").active())

func _process(delta: float) -> void:
	if get_tree().paused or match_scene.ended or not clock.running: return
	mana_elapsed += delta
	while mana_elapsed >= 5.0:
		mana_elapsed -= 5.0
		wallet.regenerate_mana()
	question_elapsed += delta
	if answer_questions and question_elapsed >= question_interval_seconds:
		question_elapsed = 0.0
		_answer_question()
	wait_remaining -= delta
	if wait_remaining <= 0.0:
		wait_remaining = decision_interval_seconds
		_decide()

func _answer_question() -> void:
	# A timed accuracy roll stands in for the computer answering; rewards still come from the deck.
	if questions_attempted > 0 and not wallet.spend_mana(10): return
	var card: Dictionary = quiz.next()
	if card.is_empty(): return
	questions_attempted += 1
	var correct: bool = rng.randf() < question_accuracy
	var reply: Dictionary
	if correct:
		reply = quiz.submit(str(card.answers[0]) if card.type != "multiple_choice" else "", int(card.get("correct", -1)))
	else:
		# Mark the attempt consumed without granting gold.
		quiz.submitted = true
		reply = {"correct": false, "gold": 0}
	if reply.correct:
		questions_correct += 1
		wallet.add_gold(int(reply.gold))

func _decide() -> void:
	if get_tree().paused or match_scene.ended or not clock.running: return
	decisions += 1
	var towers: Array = _towers()
	var counts := {"economy": 0, "attack": 0, "defense": 0}
	for tower in towers: counts[tower.kind] += 1
	var threats: int = get_tree().get_nodes_in_group("attacker_troops").size()
	# Alternate development and upgrades after establishing a small defense.
	if towers.size() >= 3 and decisions % 2 == 0 and _upgrade(towers): return
	var kind: int = 1
	if counts.attack == 0 and threats > 0: kind = 1
	elif counts.economy == 0: kind = 0
	elif counts.attack == 0: kind = 1
	elif counts.defense == 0: kind = 2
	elif counts.economy < 2 and threats < 3: kind = 0
	elif counts.attack <= counts.defense + 1: kind = 1
	else: kind = 2
	if towers.size() < maximum_towers and _build(kind): return
	_upgrade(towers)

func _towers() -> Array:
	return get_tree().get_nodes_in_group("placed_towers").filter(func(tower): return tower.health > 0 and not tower.is_queued_for_deletion())

func _build(kind: int) -> bool:
	if kind == 0 and BALANCE.economy_count(get_tree(), wallet) >= BALANCE.economy_limit: return false
	if kind < 0 or kind >= tower_scenes.size() or kind >= tower_costs.size(): return false
	if tower_costs[kind] < 0 or wallet.gold < tower_costs[kind] or tower_scenes[kind] == null: return false
	var tower = tower_scenes[kind].instantiate()
	var pad = _choose_pad(kind, tower.attack_range)
	if pad == null:
		tower.free()
		return false
	if not wallet.spend_gold(tower_costs[kind]):
		tower.free()
		return false
	spent_gold += tower_costs[kind]
	pad.occupied = true
	pad.tower = tower
	tower.resources = wallet
	tower.clock = clock
	tower.route = route
	tower.placement_pad = pad
	pad.get_parent().add_child(tower)
	tower.position = Vector3.ZERO
	tower.get_node("Selection/PickArea").input_ray_pickable = false
	return true

func _choose_pad(kind: int, radius: float) -> Node3D:
	var best: Node3D
	var best_score: float = -INF
	for pad in get_tree().get_nodes_in_group("tower_placement_pads"):
		if pad.occupied: continue
		var coverage: float = 0.0
		var closest: float = INF
		for i in 65:
			var point: Vector3 = route.to_global(route.curve.sample_baked(route.curve.get_baked_length() * i / 64.0))
			var distance: float = pad.global_position.distance_to(point)
			closest = minf(closest, distance)
			if distance <= radius: coverage += 1.0 + i / 64.0
		if kind != 0 and coverage <= 0.0: continue
		var score: float = closest if kind == 0 else coverage
		if kind != 0:
			for troop in get_tree().get_nodes_in_group("attacker_troops"):
				if troop.alive and pad.global_position.distance_to(troop.global_position) <= radius: score += 15.0 * (1.0 + troop.progress_ratio)
		if score > best_score:
			best_score = score
			best = pad
	return best

func _upgrade(towers: Array) -> bool:
	# Use normal validation: affordability, ownership and the two-choice cap.
	for tower in towers:
		if tower.upgrade_path == null: continue
		for i in tower.upgrade_path.choices.size():
			if tower.can_buy_upgrade(i):
				var before: int = wallet.gold
				if tower.buy_upgrade(i):
					spent_gold += before - wallet.gold
					return true
	return false
