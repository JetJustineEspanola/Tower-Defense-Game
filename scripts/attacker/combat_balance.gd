extends Resource
@export_range(1, 10) var economy_limit: int = 2
@export_range(1, 30) var economy_interval: float = 8.0
@export_range(0, 0.75) var disruption_fraction: float = 0.25
@export_range(1, 30) var siege_range: float = 8.0
@export_range(1, 100) var siege_damage: int = 30
@export_range(1, 60) var siege_cooldown: float = 20.0
@export_range(0, 60) var siege_initial_delay: float = 10.0
@export_range(0, 60) var siege_shared_delay: float = 8.0

func economy_count(tree: SceneTree, wallet: Node) -> int:
	var count: int = 0
	for tower in tree.get_nodes_in_group("placed_towers"):
		if tower.kind == "economy" and tower.resources == wallet and tower.health > 0 and not tower.is_queued_for_deletion(): count += 1
	return count

func disrupted(tree: SceneTree, wallet: Node) -> bool:
	for troop in tree.get_nodes_in_group("attacker_troops"):
		if troop.role == "objective" and troop.alive and not troop.is_queued_for_deletion() and troop.resources != wallet: return true
	return false
@export_range(1, 5) var trading_post_limit: int = 2
@export_range(0.5, 5) var phase_duration: float = 2.5
@export_range(5, 40) var phase_cooldown: float = 12.0
@export_range(1, 2) var phase_speed_multiplier: float = 1.4

@export var base_income_gold: int = 5
@export var base_income_seconds: float = 5.0
@export var emergency_gold_threshold: int = 50
@export var emergency_refresh_seconds: float = 20.0
@export var first_attacker_upgrade_cost: int = 80
@export var attacker_economy_limit: int = 3

func attacker_economy_count(tree: SceneTree, wallet: Node) -> int:
	var count: int = 0
	for troop in tree.get_nodes_in_group("attacker_troops"):
		if troop.alive and not troop.is_queued_for_deletion() and troop.role == "economy" and troop.resources == wallet: count += 1
	return count
