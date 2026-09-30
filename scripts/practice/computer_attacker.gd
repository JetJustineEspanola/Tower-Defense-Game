extends Node
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
## A budgeted, sequential trainer. Uses the same troop definitions and combat as the player.
@export_range(0, 120, 1) var opening_delay_seconds: float = 20.0
@export_range(0, 30, 0.5) var order_delay_seconds: float = 2.0
@export_range(1, 60, 1) var active_troop_limit: int = 24
@export var training_pattern: Array[TroopDefinition] = [
	preload("res://resources/attacker/ronel.tres"),
	preload("res://resources/attacker/canguit.tres"),
	preload("res://resources/attacker/matthew.tres"),
	preload("res://resources/attacker/ronel.tres")]
@onready var wallet: PlayerResources = $Wallet
@onready var controller = get_node("../Gameplay/CombatReview")
@onready var route: Path3D = get_node("../Gameplay/EnemyPath")
@onready var clock: MatchClock = get_node("../Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")
var next_order: int = 0
var wait_remaining: float
var income_elapsed: float = 0.0
var training_remaining: float = 0.0
var training_definition: TroopDefinition
var training_stats: Dictionary = {}
var spawned_count: int = 0

func _ready() -> void:
	wait_remaining = opening_delay_seconds

func _process(delta: float) -> void:
	if get_tree().paused or controller.ended or not clock.running: return
	if training_definition != null:
		training_remaining = maxf(0.0, training_remaining - delta)
		if training_remaining == 0.0:
			_spawn()
			training_definition = null
			training_stats = {}
			wait_remaining = order_delay_seconds
		return
	wait_remaining = maxf(0.0, wait_remaining - delta)
	if wait_remaining > 0.0 or training_pattern.is_empty(): return
	if get_tree().get_nodes_in_group("attacker_troops").size() >= active_troop_limit: return
	var definition: TroopDefinition = training_pattern[next_order % training_pattern.size()]
	if definition == null or definition.scene == null: return
	if definition.role == "economy" and BALANCE.attacker_economy_count(get_tree(), wallet) >= BALANCE.attacker_economy_limit:
		next_order += 1
		return
	if not wallet.spend_gold(definition.cost): return
	training_definition = definition
	training_stats = definition.get_stats().duplicate(true)
	training_remaining = maxf(0.1, definition.training_seconds)
	next_order += 1

func _spawn() -> void:
	var troop = training_definition.scene.instantiate()
	troop.stats = training_stats.duplicate(true)
	troop.role = training_definition.role
	troop.resources = wallet
	troop.clock = clock
	troop.arrived.connect(controller._arrived.bind(int(training_stats.base_damage)))
	route.add_child(troop)
	spawned_count += 1
