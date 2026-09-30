extends "res://scripts/attacker/attacker_match.gd"
## Only the host advances gameplay. Guests render snapshots and submit intentions.
const TOWERS = [preload("res://scenes/towers/economy_tower.tscn"), preload("res://scenes/towers/attack_tower.tscn"), preload("res://scenes/towers/defense_tower.tscn")]
const GUARD = preload("res://scenes/towers/defender.tscn")
const FIELDS = ["health", "maximum_health", "damage", "armor", "income", "interval", "attack_range", "guard_count", "guard_health", "guard_damage", "guard_capacity", "extra_targets", "burn_damage", "burn_seconds", "bounty_gold", "question_bonus", "targeting_priority", "speed", "siege_remaining", "shared_remaining", "auto_siege", "post_reserved", "stationed", "phase_remaining", "phase_wait", "overcharge_remaining", "rush_remaining", "block_capacity", "secondary_damage_fraction"]
var local_role: String = ""
var authority: bool = false
var applying: bool = false
var attacker_wallet: PlayerResources
var defender_wallet: PlayerResources
var pads: Array = []
var actors: Dictionary = {}
var next_id: int = 1
var snapshot_elapsed: float = 0.0
var visual_events: Array = []
var requests: Dictionary = {}
var questions: Dictionary = {}
var boost_cooldowns: Dictionary = {"attacker": 0.0, "defender": 0.0}
var countdown: float = -1.0
var begun: bool = false
var last_state_time: int = 0
var loading_started: int = 0
var rendered_question: int = -1
@onready var session: Node = get_node("/root/OnlineSession")
func _ready() -> void:
 if session.match_info.is_empty():
  get_tree().change_scene_to_file.call_deferred("res://scenes/UI/online_lobby.tscn")
  return
 authority = session.is_host()
 local_role = str(session.match_info.role)
 super._ready()
 attacker_wallet = hud.resources if local_role == "attacker" else $DefenderResources
 defender_wallet = hud.resources if local_role == "defender" else $DefenderResources
 resources = attacker_wallet
 for wallet in [attacker_wallet, defender_wallet]:
  wallet.gold = starting_gold
  wallet.total_gold_earned = 0
  wallet.get_node_or_null("ManaTimer")
 for roster in rosters: roster.setup(attacker_wallet, clock)
 var shop = $Gameplay/TowerShop
 shop.resources = defender_wallet
 shop.visible = local_role == "defender"
 shop.get_node("PracticeBug").hide()
 $AttackerUI.visible = local_role == "attacker"
 $TroopOrders.set_process_unhandled_input(local_role == "attacker")
 $GuardOrders.set_process_unhandled_input(local_role == "defender")
 pads = get_tree().get_nodes_in_group("tower_placement_pads")
 for pad in pads: pad.input_ray_pickable = local_role == "defender"
 hud.get_node("TopBar/Row/Health").visible = local_role == "defender"
 hud.get_node("TopBar/Row/Brand/Tagline").text = local_role.to_upper() + " • ONLINE"
 hud.get_node("Resources/ManaTimer").stop()
 clock.running = false
 if not authority:
  clock.set_process(false)
  $BaseIncome.set_process(false)
 $Experience.role = local_role
 $Experience.previous_health = base_health
 $BattleMusic.role = local_role
 for role in ["attacker", "defender"]:
  var run = preload("res://scripts/questions/question_run.gd").new()
  run.setup(session.match_info.deck)
  run.next()
  questions[role] = {"run": run, "token": 1, "emergency": 0.0, "result": "One attempt. Submit your answer.", "correct": 0, "gold": 0}
 session.match_begin.connect(_begin)
 session.command_received.connect(_command)
 session.state_received.connect(_receive_state)
 session.match_ended.connect(_present_result)
 session.room_closed.connect(_connection_lost)
 session.match_started.connect(_rematch_start)
 session.rematch_waiting.connect(_rematch_wait)
 session.status_changed.connect(_notice)
 $OnlineOverlay/Panel/Content/Home.pressed.connect(leave_online)
 $OnlineOverlay/Panel/Content/Title.text = "YOU ARE THE " + local_role.to_upper()
 $OnlineOverlay/Panel/Content/Detail.text = "Waiting for both players to load..."
 $OnlineOverlay/Panel.show()
 _sync_question(_question_data(local_role))
 _update_base_label()
 last_state_time = Time.get_ticks_msec()
 loading_started = Time.get_ticks_msec()
 hud.get_node("PauseOverlay/Center/Panel/Content/Title").text = "MATCH MENU\nOnline play keeps running"
 hud.get_node("PauseOverlay/Center/Panel/Content/Resume").text = "Back to match"
 hud.get_node("PauseOverlay/Center/Panel/Content/MainMenu").text = "Leave online match"
 session.loaded.call_deferred()
func _prepare_defender_nodes() -> void: pass
func _pause_overlay_changed() -> void:
 $AttackerUI.visible = local_role == "attacker" and not hud.get_node("PauseOverlay").visible
func online_action(action: String, data: Dictionary = {}) -> void:
 if ended or not clock.running: return
 session.command(action, data)
func online_id(actor: Node) -> int:
 if actor == null: return 0
 if not actor.has_meta("online_id"):
  if not authority: return 0
  actor.set_meta("online_id", next_id)
  actors[next_id] = weakref(actor)
  next_id += 1
 return int(actor.get_meta("online_id"))
func _actor(id: int) -> Node3D:
 var reference = actors.get(id)
 return reference.get_ref() if reference is WeakRef else null
func train(index: int) -> void:
 if applying: super.train(index)
 else: online_action("train", {"index": index})
func _begin() -> void:
 begun = true
 countdown = 5.0
func _process(delta: float) -> void:
 if local_role.is_empty(): return
 if not begun and not ended and Time.get_ticks_msec() - loading_started > 120000:
  _connection_lost("Your opponent did not finish loading. Leave and create a new room.")
 if authority:
  if begun and countdown > 0.0:
   countdown = maxf(0.0, countdown - delta)
   if countdown <= 0.0:
    clock.start()
    hud.resources.changed.emit(hud.resources.gold, hud.resources.mana)
  if clock.running and not ended:
   super._process(delta)
   for role in ["attacker", "defender"]:
    questions[role].emergency = maxf(0.0, questions[role].emergency - delta)
    boost_cooldowns[role] = maxf(0.0, boost_cooldowns[role] - delta)
   _mana_elapsed += delta
   if _mana_elapsed >= 1.0:
    _mana_elapsed -= 1.0
    attacker_wallet.regenerate_mana(); defender_wallet.regenerate_mana()
  snapshot_elapsed += delta
  if snapshot_elapsed >= 0.1 and not ended:
   snapshot_elapsed = 0.0
   _publish()
 else:
  _refresh_cards()
  for reference in actors.values():
   var actor = reference.get_ref()
   if is_instance_valid(actor) and actor.has_meta("net_position"):
    actor.global_position = actor.global_position.lerp(actor.get_meta("net_position"), minf(1.0, delta * 14.0))
  if not ended and Time.get_ticks_msec() - last_state_time > 10000:
   clock.running = false
   $OnlineOverlay/Panel.show()
   $OnlineOverlay/Panel/Content/Title.text = "CONNECTION INTERRUPTED"
   $OnlineOverlay/Panel/Content/Detail.text = "Waiting for the host..."
 _countdown_ui()
var _mana_elapsed: float = 0.0
func _countdown_ui() -> void:
 if ended: return
 if countdown > 0.0:
  $OnlineOverlay/Panel/Content/Title.text = "YOU ARE THE " + local_role.to_upper()
  $OnlineOverlay/Panel/Content/Detail.text = ("Protect the core." if local_role == "defender" else "Destroy the enemy core.") + "\nMatch starts in %d" % ceili(countdown)
  $OnlineOverlay/Panel.show()
 elif clock.running: $OnlineOverlay/Panel.hide()
func _command(message: Dictionary) -> void:
 if not authority or ended or not clock.running: return
 var sender: String = str(message.player_id)
 var request: int = int(message.request_id)
 if request <= int(requests.get(sender, 0)): return
 requests[sender] = request
 var role: String = str(message.role)
 var data: Dictionary = message.data
 var action: String = str(message.action)
 var index: int = int(data.get("index", -1))
 var actor: Node3D = _actor(int(data.get("id", 0)))
 applying = true
 match action:
  "train":
   if role == "attacker": super.train(index)
  "place":
   if role == "defender": _place(int(data.get("pad", -1)), index)
  "troop_upgrade":
   if role == "attacker" and index >= 0 and index < rosters.size(): rosters[index].buy_upgrade(int(data.get("upgrade", -1)))
  "tower_upgrade":
   if role == "defender" and is_instance_valid(actor) and actor.is_in_group("placed_towers"): actor.buy_upgrade(index)
  "tower_priority":
   if role == "defender" and is_instance_valid(actor) and actor.is_in_group("placed_towers"): actor.set_targeting_priority(index)
  "troop_priority", "troop_auto", "siege":
   if role == "attacker" and is_instance_valid(actor) and actor.is_in_group("attacker_troops"):
    if action == "troop_priority" and index >= 0 and index <= 3: actor.targeting_priority = index
    elif action == "troop_auto": actor.auto_siege = bool(data.get("value", false))
    elif action == "siege": actor.fire_siege()
  "guard":
   if role == "defender" and is_instance_valid(actor) and actor.is_in_group("defenders"):
    var target: Vector3 = _vector(data.get("position", []))
    var offset: float = route.curve.get_closest_offset(route.to_local(target))
    var destination: Vector3 = route.to_global(route.curve.sample_baked(offset))
    if target.distance_to(destination) < 1.0 and actor.get_parent().global_position.distance_to(destination) <= actor.get_parent().attack_range: actor.walk_to(destination)
  "answer": _answer(role, data)
  "next_question": _next_question(role, data)
  "boost": _boost(role, actor)
 applying = false
func _place(pad_index: int, index: int) -> void:
 if pad_index < 0 or pad_index >= pads.size() or index < 0 or index >= TOWERS.size(): return
 var pad = pads[pad_index]
 if pad.occupied: return
 if index == 0 and BALANCE.economy_count(get_tree(), defender_wallet) >= BALANCE.economy_limit: return
 var cost: int = $Gameplay/TowerShop.costs[index]
 if not defender_wallet.spend_gold(cost): return
 var tower = TOWERS[index].instantiate()
 tower.resources = defender_wallet; tower.route = route; tower.clock = clock; tower.placement_pad = pad
 pad.occupied = true; pad.tower = tower
 pad.get_parent().add_child(tower)
 tower.position = Vector3.ZERO
 if local_role == "defender": tower.selected.connect($Gameplay/TowerShop._select_tower)
 online_id(tower)
func _wallet(role: String) -> PlayerResources: return attacker_wallet if role == "attacker" else defender_wallet
func _answer(role: String, data: Dictionary) -> void:
 var state: Dictionary = questions[role]
 if int(data.get("token", -1)) != state.token: return
 var outcome: Dictionary = state.run.submit(str(data.get("answer", "")).left(10000), int(data.get("choice", -1)))
 if not outcome.accepted: return
 if outcome.correct:
  var reward: int = int(outcome.gold)
  if role == "defender":
   var bonus: int = 0
   for tower in get_tree().get_nodes_in_group("placed_towers"): bonus = maxi(bonus, tower.question_bonus)
   reward += bonus
  _wallet(role).add_gold(reward)
  state.correct += 1; state.gold += reward
  state.result = "Correct! +%d gold" % reward
 else: state.result = "Not quite. Try this card next cycle."
 state.result += "\n" + str(state.run.current.get("explanation", ""))
func _next_question(role: String, data: Dictionary) -> void:
 var state: Dictionary = questions[role]
 if int(data.get("token", -1)) != state.token: return
 var wallet: PlayerResources = _wallet(role)
 if wallet.gold < BALANCE.emergency_gold_threshold and state.emergency <= 0.0: state.emergency = BALANCE.emergency_refresh_seconds
 elif not wallet.spend_mana(hud.question_cost): return
 state.run.next(); state.token += 1; state.result = "One attempt. Submit your answer."
func _boost(role: String, actor: Node3D) -> void:
 if boost_cooldowns[role] > 0.0: return
 var affected: Array = []
 if role == "attacker":
  affected = get_tree().get_nodes_in_group("attacker_troops")
  for troop in affected: troop.rush_remaining = 6.0; troop.rush_multiplier = 1.5
 elif is_instance_valid(actor) and actor.is_in_group("placed_towers"):
  actor.overcharge_remaining = 6.0; actor.overcharge_multiplier = 1.5
  actor.get_node("ActionTimer").start(actor.effective_interval())
  affected.append(actor)
 if affected.is_empty(): return
 boost_cooldowns[role] = 40.0
 for item in affected:
  $Experience._boost_aura(item)
  record_visual(item, "boost", {})
func _question_data(role: String) -> Dictionary:
 var state: Dictionary = questions[role]
 return {"card": state.run.current, "cycle": state.run.cycle, "token": state.token, "answered": state.run.submitted, "emergency": state.emergency, "result": state.result, "correct": state.correct, "gold": state.gold}
func _sync_question(state: Dictionary) -> void:
 if state.is_empty(): return
 if rendered_question != int(state.token) or hud.question_run.current.get("id") != state.card.get("id"):
  rendered_question = int(state.token)
  hud.question_run.current = state.card
  hud.question_run.cycle = int(state.cycle)
  hud._render_card(state.card)
 hud.set_meta("question_token", rendered_question)
 hud.answered = state.answered
 hud.emergency_remaining = float(state.emergency)
 hud.get_node("%ResultLabel").text = str(state.result)
 hud._refresh_question()
 if int(state.correct) > $Experience.questions_correct:
  $Experience._question_reward(int(state.gold) - $Experience.question_gold)
 $Experience.questions_correct = int(state.correct)
 $Experience.question_gold = int(state.gold)
func _update_base_label() -> void:
 $Gameplay/AlliedBase/BaseFeedback.set_health(base_health, base_maximum_health)
 $Gameplay/AlliedBase/TargetHealth.text = "YOUR CORE" if local_role == "defender" else "ENEMY CORE"
 hud.set_base_health(base_health, base_maximum_health)
func _finish(attacker_won: bool) -> void:
 if not authority or ended: return
 ended = true; clock.running = false
 orders = [{}, {}, {}]
 _publish()
 session.end_match("attacker" if attacker_won else "defender")
func _present_result(winner: String) -> void:
 ended = true; clock.running = false
 $OnlineOverlay/Panel.hide()
 $Gameplay/TowerShop._close(); $Gameplay/TowerShop/UpgradeSidebar.close(); sidebar.close()
 $MatchResult.present(winner == local_role, local_role, clock, hud.resources, base_health, base_maximum_health)
 $MatchResult/Screen/Content/Buttons/Again.text = "REMATCH • SWAP ROLES"
func _rematch_wait(count: int) -> void:
 $MatchResult/Screen/Content/Buttons/Again.text = "REMATCH READY %d / 2" % count
func request_rematch() -> void:
 session.rematch()
 $MatchResult/Screen/Content/Buttons/Again.disabled = true
func _rematch_start() -> void:
 get_tree().paused = false
 get_tree().reload_current_scene()
func _connection_lost(message: String) -> void:
 ended = true; clock.running = false
 $MatchResult.hide()
 hud.get_node("PauseOverlay").hide()
 $OnlineOverlay/Panel.show()
 $OnlineOverlay/Panel/Content/Title.text = "MATCH DISCONNECTED"
 $OnlineOverlay/Panel/Content/Detail.text = message
func leave_online() -> void:
 session.leave(); get_tree().paused = false
 get_tree().change_scene_to_file("res://scenes/UI/online_lobby.tscn")
func _notice(message: String) -> void: $Experience.notice(message)
func _exit_tree() -> void:
 if session == null: return
 for pair in [[session.match_begin, _begin], [session.command_received, _command], [session.state_received, _receive_state], [session.match_ended, _present_result], [session.room_closed, _connection_lost], [session.match_started, _rematch_start], [session.rematch_waiting, _rematch_wait], [session.status_changed, _notice]]:
  if pair[0].is_connected(pair[1]): pair[0].disconnect(pair[1])
func _vector(value: Array) -> Vector3:
 if value.size() != 3: return Vector3.ZERO
 var result := Vector3(float(value[0]), float(value[1]), float(value[2]))
 return result if result.is_finite() else Vector3.ZERO
func _array(value: Vector3) -> Array: return [value.x, value.y, value.z]
func record_visual(actor: Node, event: String, data: Dictionary) -> void:
 if not authority or not is_instance_valid(actor) or not actor is Node3D: return
 if not actor.is_in_group("placed_towers") and not actor.is_in_group("attacker_troops") and not actor.is_in_group("defenders"): return
 visual_events.append({"id": online_id(actor), "event": event, "data": data})
func _publish() -> void:
 if not authority: return
 for id in actors.keys():
  if not is_instance_valid(_actor(id)): actors.erase(id)
 var entities: Array = []
 for group in ["placed_towers", "attacker_troops", "defenders"]:
  for actor in get_tree().get_nodes_in_group(group):
   if actor.is_queued_for_deletion(): continue
   var entry: Dictionary = {"id": online_id(actor), "group": group, "position": _array(actor.global_position), "yaw": actor.get_node("Model").global_rotation.y, "values": {}}
   for property in actor.get_property_list():
    var key: String = str(property.name)
    if key in FIELDS: entry.values[key] = actor.get(key)
   if group == "placed_towers":
    entry.kind = ["economy", "attack", "defense"].find(actor.kind)
    entry.pad = pads.find(actor.placement_pad)
    entry.purchased = Array(actor.purchased)
   elif group == "attacker_troops":
    entry.kind = ["objective", "siege", "economy"].find(actor.role)
    entry.stats = actor.stats
    entry.progress = actor.progress
    entry.blocker = online_id(actor.blocker) if is_instance_valid(actor.blocker) else 0
   else:
    entry.parent = online_id(actor.get_parent())
    entry.rally = _array(actor.rally_position)
   entry.moving = actor.get_node("CharacterAnimation").moving
   entities.append(entry)
 var wallets: Dictionary = {}
 for role in ["attacker", "defender"]:
  var wallet: PlayerResources = _wallet(role)
  wallets[role] = {"gold": wallet.gold, "mana": wallet.mana, "earned": wallet.total_gold_earned}
 var upgrades: Array = []
 for roster in rosters: upgrades.append({"stats": roster.stats, "purchased": Array(roster.purchased)})
 var state: Dictionary = {"entities": entities, "wallets": wallets, "remaining": clock.remaining, "running": clock.running, "countdown": countdown, "health": base_health, "ended": ended, "orders": orders, "rosters": upgrades, "questions": {"attacker": _question_data("attacker"), "defender": _question_data("defender")}, "cooldowns": boost_cooldowns, "visuals": visual_events.duplicate(true), "bugs_defeated": $Experience.bugs_defeated, "towers_destroyed": $Experience.towers_destroyed, "tower_damage": $Experience.tower_damage}
 session.snapshot(state)
 visual_events.clear()
 _sync_question(state.questions[local_role])
 $Experience.cooldown = boost_cooldowns[local_role]
func _receive_state(state: Dictionary) -> void:
 if authority: return
 last_state_time = Time.get_ticks_msec()
 countdown = float(state.countdown)
 clock.remaining = float(state.remaining); clock.running = bool(state.running); clock._update_display()
 var previous: int = base_health
 base_health = int(state.health); ended = bool(state.ended)
 if base_health < previous: $Gameplay/AlliedBase/BaseFeedback.hit(previous, base_health, true)
 _update_base_label()
 for role in ["attacker", "defender"]:
  var wallet: PlayerResources = _wallet(role)
  wallet.gold = int(state.wallets[role].gold); wallet.mana = int(state.wallets[role].mana); wallet.total_gold_earned = int(state.wallets[role].earned)
  wallet.changed.emit(wallet.gold, wallet.mana)
 orders.assign(state.orders)
 for i in rosters.size():
  rosters[i].stats = state.rosters[i].stats
  rosters[i].purchased.assign(state.rosters[i].purchased)
  rosters[i].upgraded.emit()
 var present: Dictionary = {}
 for entry in state.entities:
  var id: int = int(entry.id)
  present[id] = true
  var actor: Node3D = _actor(id)
  if not is_instance_valid(actor): actor = _replica(entry)
  if actor == null: continue
  var previous_position: Vector3 = actor.global_position
  for key in entry.values: actor.set(key, entry.values[key])
  if entry.group == "placed_towers":
   actor.purchased.assign(entry.purchased); actor._refresh_effects(); actor.upgraded.emit()
   actor.get_node("Selection/RangeCircle").scale = Vector3(actor.attack_range, 1.0, actor.attack_range)
   if actor.kind == "economy": actor.get_node("NameLabel").text = "ECONOMY | DISRUPTED" if BALANCE.disrupted(get_tree(), defender_wallet) else "ECONOMY"
  elif entry.group == "attacker_troops":
   actor.progress = float(entry.progress); actor.stats = entry.stats
   actor.get_node("AbilityStatus").text = "PHASE DASH" if actor.phase_remaining > 0.0 else ("TRADING POST" if actor.stationed else ("TO TRADING POST" if actor.post_reserved else ""))
   actor.get_node("AbilityStatus").visible = not actor.get_node("AbilityStatus").text.is_empty()
  else:
   actor.rally_position = _vector(entry.rally)
   actor._update()
  actor.global_position = previous_position
  actor.set_meta("net_position", _vector(entry.position))
  actor.get_node("CharacterAnimation").set_moving(bool(entry.moving))
  actor.get_node("Model").global_rotation.y = float(entry.yaw)
 for entry in state.entities:
  if entry.group == "attacker_troops" and is_instance_valid(_actor(int(entry.id))): _actor(int(entry.id)).blocker = _actor(int(entry.blocker))
 for event in state.visuals: _play_visual(event)
 for id in actors.keys():
  if not present.has(id):
   var actor = _actor(id)
   if is_instance_valid(actor):
    if actor.is_in_group("placed_towers") and is_instance_valid(actor.placement_pad): actor.placement_pad.occupied = false; actor.placement_pad.tower = null
    actor.queue_free()
   actors.erase(id)
 _sync_question(state.questions[local_role])
 $Experience.cooldown = float(state.cooldowns[local_role])
 $Experience.bugs_defeated = int(state.bugs_defeated); $Experience.towers_destroyed = int(state.towers_destroyed)
 $Experience.tower_damage = state.get("tower_damage", {})
func _replica(entry: Dictionary) -> Node3D:
 var actor: Node3D
 if entry.group == "placed_towers":
  var index: int = int(entry.pad)
  if index < 0 or index >= pads.size(): return null
  actor = TOWERS[int(entry.kind)].instantiate()
  actor.resources = defender_wallet; actor.route = route; actor.clock = clock; actor.placement_pad = pads[index]
  pads[index].occupied = true; pads[index].tower = actor
  pads[index].get_parent().add_child(actor)
  actor.position = Vector3.ZERO
  if local_role == "defender": actor.selected.connect($Gameplay/TowerShop._select_tower)
 elif entry.group == "attacker_troops":
  actor = rosters[int(entry.kind)].definition.scene.instantiate()
  actor.stats = entry.stats; actor.role = rosters[int(entry.kind)].definition.role
  actor.resources = attacker_wallet; actor.clock = clock
  route.add_child(actor)
 else:
  var tower = _actor(int(entry.parent))
  if tower == null: return null
  actor = GUARD.instantiate(); actor.clock = clock
  tower.add_child(actor)
 actor.set_meta("online_id", int(entry.id))
 actors[int(entry.id)] = weakref(actor)
 actor.global_position = _vector(entry.position)
 actor.set_process(false); actor.set_physics_process(false)
 for child in actor.get_children():
  if child is Timer: child.stop()
 var animation = actor.get_node("CharacterAnimation")
 for connection in animation.impact.get_connections(): animation.impact.disconnect(connection.callable)
 return actor
func _play_visual(event: Dictionary) -> void:
 var actor = _actor(int(event.id))
 if not is_instance_valid(actor): return
 var data: Dictionary = event.data
 match str(event.event):
  "action": actor.get_node("CharacterAnimation").play_action(float(data.duration))
  "hit": actor.get_node("HealthFeedback").hit(int(data.before), int(data.after))
  "boost": $Experience._boost_aura(actor)
  "effect":
   var effect = actor.get_node_or_null(str(data.path))
   if effect != null and effect.has_method("play"):
    effect.global_position = _vector(data.position)
    effect.global_rotation = _vector(data.rotation)
    if effect.has_method("aim_attack"): effect.aim_attack(float(data.get("distance", 1.0)))
    effect.play(int(data.amount))
