extends Node3D
signal upgraded
@export var definition: TroopDefinition
var upgrade_path: TowerUpgradePath
var purchased: Array[StringName] = []
var resources: PlayerResources
var clock: MatchClock
var stats: Dictionary
var buying: bool = false
func setup(wallet: PlayerResources, match_clock: MatchClock) -> void:
	resources = wallet
	clock = match_clock
	upgrade_path = definition.upgrades
	stats = definition.get_stats()
func set_selected(_value: bool) -> void:
	pass
func can_buy_upgrade(index: int) -> bool:
	if buying or clock == null or not clock.running or get_tree().paused: return false
	if index < 0 or index >= upgrade_path.choices.size() or purchased.size() >= upgrade_path.choice_limit: return false
	var choice: TowerUpgrade = upgrade_path.choices[index]
	return not purchased.has(choice.id) and choice.cost >= 0 and resources.gold >= choice.cost
func buy_upgrade(index: int) -> bool:
	if not can_buy_upgrade(index): return false
	var choice: TowerUpgrade = upgrade_path.choices[index]
	buying = true
	purchased.append(choice.id)
	if not resources.spend_gold(choice.cost):
		purchased.erase(choice.id)
		buying = false
		return false
	stats.health += choice.troop_health_bonus
	stats.speed *= choice.speed_multiplier
	stats.armor += choice.armor_bonus
	stats.damage += choice.damage_bonus
	stats.attack_range += choice.range_bonus
	stats.base_damage += choice.base_damage_bonus
	stats.training = maxf(0.2, stats.training * choice.training_multiplier)
	stats.income += choice.income_bonus
	if definition.role == "economy":
		stats.income_interval = maxf(0.2, stats.income_interval * choice.interval_multiplier)
	else:
		stats.interval = maxf(0.2, stats.interval * choice.interval_multiplier)
	buying = false
	upgraded.emit()
	return true
func get_stats_text() -> String:
	var info: String = "HP: %d  Armor: %d  Speed: %.2f\nTraining: %.1fs  Base damage: %d" % [stats.health, stats.armor, stats.speed, stats.training, stats.base_damage]
	if definition.role == "siege":
		info += "\nTower damage: %d / %.1fs" % [stats.damage, stats.interval]
	if definition.role == "economy":
		info += "\nIncome: +%d gold / %.1fs" % [stats.income, stats.income_interval]
	return info + "\nApplies to new training orders."
