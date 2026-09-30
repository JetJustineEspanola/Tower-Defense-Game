class_name TroopDefinition
extends Resource
@export var character_name: String
@export_enum("objective", "siege", "economy") var role: String
@export var scene: PackedScene
@export var upgrades: TowerUpgradePath
@export var cost: int = 50
@export var training_seconds: float = 3.0
@export var health: int = 90
@export var speed: float = 0.9
@export var armor: int = 0
@export var damage: int = 20
@export var attack_range: float = 2.5
@export var interval: float = 1.0
@export var base_damage: int = 15
@export var income: int = 0
@export var income_interval: float = 5.0
func get_stats() -> Dictionary:
	return {"health": health, "speed": speed, "armor": armor, "damage": damage,
		"attack_range": attack_range, "interval": interval, "base_damage": base_damage,
		"income": income, "income_interval": income_interval, "training": training_seconds}
