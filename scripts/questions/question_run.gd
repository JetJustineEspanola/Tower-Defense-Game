extends RefCounted
const STORE = preload("res://scripts/questions/deck_store.gd")
var cards: Array = []
var queue: Array = []
var current: Dictionary = {}
var submitted: bool = false
var cycle: int = 0
var rng := RandomNumberGenerator.new()
func setup(deck: Dictionary, seed_value: int = -1) -> void:
	cards.clear()
	queue.clear()
	current = {}
	cycle = 0
	if seed_value < 0: rng.randomize()
	else: rng.seed = seed_value
	for card in deck.cards:
		if card.type in deck.enabled_types: cards.append(card.duplicate(true))
func next() -> Dictionary:
	if cards.is_empty(): return {}
	if queue.is_empty():
		cycle += 1
		for i in cards.size(): queue.append(i)
		for i in range(queue.size() - 1, 0, -1):
			var j: int = rng.randi_range(0, i)
			var temp = queue[i]
			queue[i] = queue[j]
			queue[j] = temp
		if queue.size() > 1 and not current.is_empty() and cards[queue.back()].id == current.id:
			var temp = queue[0]
			queue[0] = queue.back()
			queue[queue.size() - 1] = temp
	submitted = false
	current = cards[queue.pop_back()]
	return current
func submit(answer: String, choice: int = -1) -> Dictionary:
	if submitted or current.is_empty(): return {"accepted": false, "correct": false, "gold": 0}
	submitted = true
	var correct: bool = STORE.matches(current, answer, choice)
	return {"accepted": true, "correct": correct, "gold": int(current.get("reward", 25)) if correct else 0}
