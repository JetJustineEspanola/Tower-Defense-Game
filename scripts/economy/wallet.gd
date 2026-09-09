class_name BattleWallet
extends RefCounted

static func spend(wallet: Dictionary, amount: int) -> bool:
	if amount < 0 or int(wallet.gold) < amount:
		return false
	wallet.gold -= amount
	wallet.spent += amount
	return true

static func earn(wallet: Dictionary, amount: int, cap: int) -> void:
	var granted: int = mini(amount, cap - int(wallet.gold))
	wallet.gold += granted
	wallet.earned += granted
