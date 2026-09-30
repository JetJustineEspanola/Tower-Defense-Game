class_name PlayerResources
extends Node

signal changed(gold: int, mana: int)
@export_range(0, 100000) var starting_gold: int = 100
@export_range(0, 1000) var maximum_mana: int = 50
@export_range(0, 1000) var starting_mana: int = 50
var gold: int
var total_gold_earned: int = 0
var mana: int

func _ready() -> void:
	gold = starting_gold
	mana = mini(starting_mana, maximum_mana)

func add_gold(amount: int) -> bool:
	if amount <= 0:
		return false
	gold += amount
	total_gold_earned += amount
	changed.emit(gold, mana)
	return true

func spend_gold(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	changed.emit(gold, mana)
	return true

func spend_mana(amount: int) -> bool:
	if amount < 0 or mana < amount:
		return false
	mana -= amount
	changed.emit(gold, mana)
	return true

func regenerate_mana() -> void:
	if mana < maximum_mana:
		mana += 1
		changed.emit(gold, mana)
