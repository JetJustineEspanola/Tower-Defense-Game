class_name TowerUpgrade
extends Resource
## A single purchasable ability. Never store per-tower ownership in this resource.
@export var id: StringName
@export var title: String
@export var icon: Texture2D
@export var short_description: String
@export_multiline var description: String
@export_range(0, 10000) var cost: int = 80
@export var damage_bonus: int = 0
@export var interval_multiplier: float = 1.0
@export var range_bonus: float = 0.0
@export var income_bonus: int = 0
@export var extra_targets: int = 0
@export var secondary_damage_fraction: float = 0.5
@export var burn_damage: int = 0
@export var burn_seconds: float = 0.0
@export var guard_health_bonus: int = 0
@export var guard_damage_bonus: int = 0
@export var guard_count_bonus: int = 0
@export var guard_capacity_bonus: int = 0
@export var bounty_gold: int = 0
@export var question_bonus: int = 0
@export var health_bonus: int = 0
@export var armor_bonus: int = 0
@export var speed_multiplier: float = 1.0
@export var training_multiplier: float = 1.0
@export var base_damage_bonus: int = 0
@export var troop_health_bonus: int = 0
