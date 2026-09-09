class_name BattleSimulation
extends RefCounted

var catalog: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/catalog.json"))
var map: BattleMapData = BattleMapData.new()
var state: Dictionary = {}
var next_entity: int = 1
var last_commands: Dictionary = {}
var cached_results: Dictionary = {}
var question_indices: Dictionary = {}
var question_cursors: Dictionary = {}
var reward_history: Dictionary = {}
var income_time: float = 0.0

func start(match_id: int, attacker: int, defender: int, duration: int = 720) -> void:
	state = {"match_id":match_id,"tick":0,"phase":"preparation","phase_left":float(catalog.rules.preparation),"remaining":float(clampi(duration,600,900)),"elapsed":0.0,"attacker":attacker,"defender":defender,"base_hp":int(catalog.rules.base_hp),"wallets":{},"towers":{},"troops":{},"orders":[],"blueprint_abilities":[],"outcome":{},"questions":{}}
	next_entity = 1
	last_commands.clear()
	cached_results.clear()
	question_indices.clear()
	question_cursors.clear()
	reward_history.clear()
	income_time = 0.0
	for peer: int in [attacker, defender]:
		state.wallets[peer] = {"gold":int(catalog.rules.starting_gold),"mana":int(catalog.rules.starting_mana),"earned":0,"spent":0,"trained":0,"built":0,"killed":0,"answered":0,"correct":0}
		question_cursors[peer] = 0
		reward_history[peer] = []

func command(peer: int, match_id: int, sequence: int, action: String, payload: Dictionary) -> String:
	if state.is_empty() or match_id != int(state.match_id) or not state.wallets.has(peer):
		return "Stale match or unknown player."
	var cache_key: String = "%s:%s" % [peer, sequence]
	if cached_results.has(cache_key):
		return cached_results[cache_key]
	if sequence <= int(last_commands.get(peer, 0)):
		return "Stale command."
	last_commands[peer] = sequence
	var result: String = _execute(peer, action, payload)
	cached_results[cache_key] = result
	if cached_results.size() > 512:
		cached_results.erase(cached_results.keys()[0])
	return result

func _execute(peer: int, action: String, payload: Dictionary) -> String:
	if state.phase not in ["preparation", "active"]:
		return "The match has ended."
	var wallet: Dictionary = state.wallets[peer]
	match action:
		"build":
			if peer != int(state.defender):
				return "Only the defender can build."
			if not payload.get("node") is int or int(payload.node) < 0 or int(payload.node) >= map.nodes.size():
				return "Invalid deployment node."
			var node_id: int = payload.node
			if state.towers.has(node_id):
				return "Deployment node is occupied."
			var definition: Dictionary = catalog.towers.pulse_spire
			if not BattleWallet.spend(wallet, int(definition.cost)):
				return "Not enough gold."
			state.towers[node_id] = {"id":next_entity,"node":node_id,"hp":definition.hp,"cooldown":0.0,"abilities":[],"shot":0,"target":-1}
			next_entity += 1
			wallet.built += 1
		"train":
			if peer != int(state.attacker):
				return "Only the attacker can train."
			var stats: Dictionary = catalog.troops.core_runner.duplicate(true)
			var abilities: Array = state.blueprint_abilities.duplicate()
			if "brood_link" in abilities:
				stats.count = 4
			if "sprint_runes" in abilities:
				stats.speed *= 1.2
			if "thick_carapace" in abilities:
				stats.hp *= 1.4
			if "core_charge" in abilities:
				stats.base_damage = 45
			var population: int = state.troops.size()
			for order: Dictionary in state.orders:
				population += int(order.stats.count)
			if state.orders.size() >= int(catalog.rules.queue_cap) or population + int(stats.count) > int(catalog.rules.population_cap):
				return "Training queue or population is full."
			if not BattleWallet.spend(wallet, int(stats.cost)):
				return "Not enough gold."
			state.orders.append({"id":next_entity,"remaining":float(stats.training),"stats":stats,"abilities":abilities})
			next_entity += 1
		"ability":
			var ability: String = str(payload.get("ability", ""))
			if not catalog.abilities.has(ability) or not catalog.abilities[ability].get("enabled", true):
				return "Ability unavailable in this slice."
			var selected: Array
			var costs: Array
			var allowed: Array
			if peer == int(state.defender):
				if not payload.get("node") is int or not state.towers.has(payload.node):
					return "Select an owned tower."
				selected = state.towers[payload.node].abilities
				costs = catalog.ability_costs.tower
				allowed = catalog.towers.pulse_spire.abilities
			else:
				selected = state.blueprint_abilities
				costs = catalog.ability_costs.troop
				allowed = catalog.troops.core_runner.abilities
			if ability not in allowed or ability in selected or selected.size() >= 2:
				return "Choose at most two distinct abilities from this type."
			if not BattleWallet.spend(wallet, int(costs[selected.size()])):
				return "Not enough gold."
			# Cooldown stores normalized cycle progress, unaffected by rate changes.
			selected.append(ability)
		"question":
			if state.phase != "active":
				return "Questions open when active play starts."
			if question_indices.has(peer):
				return "Submit the current question first."
			var index: int = int(question_cursors[peer])
			if index >= QuestionRepository.questions.size():
				return "Prototype question pack complete."
			if int(wallet.mana) < int(catalog.rules.question_cost):
				return "Not enough mana."
			wallet.mana -= int(catalog.rules.question_cost)
			question_indices[peer] = index
			question_cursors[peer] = index + 1
			state.questions[peer] = QuestionRepository.public_question(index)
		"answer":
			if state.phase != "active" or not question_indices.has(peer):
				return "No active question."
			if not payload.get("answer") is String or payload.answer.length() > 500:
				return "Invalid answer."
			var index: int = question_indices[peer]
			question_indices.erase(peer)
			state.questions.erase(peer)
			wallet.answered += 1
			var correct: bool = QuestionRepository.is_correct(index, payload.answer)
			if correct:
				wallet.correct += 1
				var recent: Array = []
				var awarded: int = 0
				for entry: Dictionary in reward_history[peer]:
					if float(state.elapsed) - float(entry.time) < 60.0:
						recent.append(entry)
						awarded += int(entry.amount)
				var reward: int = mini(int(QuestionRepository.questions[index].reward), maxi(0,120-awarded))
				BattleWallet.earn(wallet,reward,int(catalog.rules.gold_cap))
				recent.append({"time":state.elapsed,"amount":reward})
				reward_history[peer] = recent
			return ("Correct. " if correct else "Incorrect. ") + str(QuestionRepository.questions[index].explanation)
		"surrender":
			finish(int(state.defender) if peer == int(state.attacker) else int(state.attacker), "Opponent surrendered")
		_:
			return "Unknown command."
	return "Accepted"

func step(delta: float) -> void:
	if state.is_empty() or state.phase == "results":
		return
	state.tick += 1
	if state.phase == "preparation":
		state.phase_left = maxf(0.0, float(state.phase_left) - delta)
		if float(state.phase_left) <= 0.0:
			state.phase = "active"
		return
	state.elapsed += delta
	state.remaining = maxf(0.0, float(state.remaining) - delta)
	var completed: Array = []
	for i: int in range(mini(int(catalog.rules.training_lanes), state.orders.size())):
		var order: Dictionary = state.orders[i]
		order.remaining -= delta
		if float(order.remaining) <= 0.0:
			completed.append(order)
	for order: Dictionary in completed:
		state.orders.erase(order)
		for i: int in range(int(order.stats.count)):
			state.troops[next_entity] = {"id":next_entity,"progress":0.0,"hp":float(order.stats.hp),"speed":float(order.stats.speed),"base_damage":int(order.stats.base_damage),"abilities":order.abilities.duplicate(),"slow_until":0.0,"offset":i}
			next_entity += 1
			state.wallets[state.attacker].trained += 1
	for unit: Dictionary in state.troops.values():
		unit.progress += float(unit.speed) * delta * (0.8 if float(unit.slow_until) > float(state.elapsed) else 1.0)
	for tower: Dictionary in state.towers.values():
		var abilities: Array = tower.abilities
		tower.cooldown = maxf(0.0, float(tower.cooldown) - delta * (1.25 if "overclock" in abilities else 1.0))
		if float(tower.cooldown) > 0.0:
			continue
		var targets: Array = state.troops.values().filter(func(unit: Dictionary) -> bool: return float(unit.hp) > 0.0 and map.nodes[int(tower.node)].distance_to(map.point(unit.progress)) <= float(catalog.towers.pulse_spire.range) + (2.0 if "long_lens" in abilities else 0.0))
		targets.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.progress > b.progress if a.progress != b.progress else a.id < b.id)
		if targets.is_empty():
			continue
		var primary: Dictionary = targets[0]
		var damage: float = float(catalog.towers.pulse_spire.damage)
		primary.hp -= damage
		tower.cooldown = float(catalog.towers.pulse_spire.interval)
		tower.shot += 1
		tower.target = primary.id
		tower.target_progress = primary.progress
		if "frost_script" in abilities:
			primary.slow_until = float(state.elapsed) + 2.0
		var neighbors: Array = state.troops.values().filter(func(unit: Dictionary) -> bool: return unit.id != primary.id and float(unit.hp) > 0.0)
		neighbors.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			var da: float = map.point(a.progress).distance_to(map.point(primary.progress))
			var db: float = map.point(b.progress).distance_to(map.point(primary.progress))
			return da < db if not is_equal_approx(da, db) else a.id < b.id)
		var splashes: int = 0
		var forked: bool = false
		for neighbor: Dictionary in neighbors:
			var distance: float = map.point(neighbor.progress).distance_to(map.point(primary.progress))
			if "forked_circuit" in abilities and not forked and distance <= 3.0:
				neighbor.hp -= damage * 0.5
				forked = true
			if "arc_burst" in abilities and splashes < 3 and distance <= 2.0:
				neighbor.hp -= damage * 0.4
				splashes += 1
	for id: int in state.troops.keys():
		var unit: Dictionary = state.troops[id]
		if float(unit.hp) <= 0.0:
			state.troops.erase(id)
			state.wallets[state.defender].killed += 1
		elif float(unit.progress) >= map.length:
			state.base_hp = maxi(0, int(state.base_hp) - int(unit.base_damage))
			state.troops.erase(id)
	income_time += delta
	while income_time >= 1.0:
		income_time -= 1.0
		for peer: int in state.wallets:
			var wallet: Dictionary = state.wallets[peer]
			BattleWallet.earn(wallet, int(catalog.rules.attacker_income if peer == int(state.attacker) else catalog.rules.defender_income), int(catalog.rules.gold_cap))
			wallet.mana = mini(int(catalog.rules.mana_cap), int(wallet.mana) + 1)
	# Base contacts resolve before survival on the terminal tick.
	if int(state.base_hp) <= 0:
		finish(int(state.attacker), "Code Core destroyed")
	elif float(state.remaining) <= 0.0:
		finish(int(state.defender), "Time survived")

func finish(winner: int, reason: String) -> void:
	if state.is_empty() or state.phase == "results":
		return
	state.phase = "results"
	state.outcome = {"winner":winner,"reason":reason,"tick":state.tick}

func snapshot_for(peer: int) -> Dictionary:
	var snapshot: Dictionary = state.duplicate(true)
	if state.phase != "results":
		for other: int in snapshot.wallets.keys():
			if other != peer:
				snapshot.wallets.erase(other)
	if peer != int(state.attacker):
		snapshot.orders = []
	for other: int in snapshot.questions.keys():
		if other != peer:
			snapshot.questions.erase(other)
	return snapshot
