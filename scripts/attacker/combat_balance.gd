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