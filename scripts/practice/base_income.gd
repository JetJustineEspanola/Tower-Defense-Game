extends Node
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
var elapsed: float = 0.0
@onready var hud = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest")
func _process(delta: float) -> void:
	if get_tree().paused or not hud.get_node("MatchClock").running: return
	elapsed += delta
	while elapsed >= maxf(0.1, BALANCE.base_income_seconds):
		elapsed -= maxf(0.1, BALANCE.base_income_seconds)
		hud.resources.add_gold(BALANCE.base_income_gold)
		var opponent = get_parent().get_node_or_null("DefenderResources")
		if opponent == null: opponent = get_parent().get_node_or_null("ComputerAttacker/Wallet")
		if opponent != null and opponent != hud.resources: opponent.add_gold(BALANCE.base_income_gold)