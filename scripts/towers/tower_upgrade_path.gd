class_name TowerUpgradePath
extends Resource
@export var character_name: String
@export var role: String
@export var portrait: Texture2D
@export_range(1, 5) var choice_limit: int = 2
@export var choices: Array[TowerUpgrade] = []
