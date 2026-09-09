extends Node

var failures: int = 0
var checks: int = 0
var suite: String = "rules"
var finished: bool = false
var sent_actions: Dictionary = {}
var first_attacker: int = 0
var seen_results: Array[int] = []
var result_wait: float = 0.0
var start_time: int = 0
var output_dir: String = "res://tests/artifacts"
var accelerated_time: float = 0.0

func _ready() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--suite="):
			suite = arg.trim_prefix("--suite=")
	DirAccess.make_dir_recursive_absolute(output_dir)
	# Keep the runner alive across real screen transitions.
	get_tree().current_scene = null
	start_time = Time.get_ticks_msec()
	_run.call_deferred()

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func done() -> void:
	finished = true
	print("TEST SUMMARY %s: %s checks / %s failures" % [suite, checks, failures])
	NetworkManager.leave()
	get_tree().quit(0 if failures == 0 else 1)

func _run() -> void:
	if suite == "rules":
		_rules()
		done()
	elif suite == "ui":
		await _ui()
		done()
	elif suite == "quit":
		SceneRouter.go("menu")
		await get_tree().create_timer(0.2).timeout
		print("PASS: Quit button invoked")
		_button("Quit").pressed.emit()
	elif suite.begins_with("fault-"):
		await _faults()
		done()
	elif suite == "host":
		check(NetworkManager.host("Integration","Host",24660) == OK,"Host socket opens")
	elif suite == "client":
		NetworkManager.discovery.browse()
		await get_tree().create_timer(1.5).timeout
		check(not NetworkManager.discovery.sessions.is_empty(),"UDP localhost discovery receives host")
		check(NetworkManager.join("bad-ip","Guest",24660) != OK,"Invalid IP rejected")
		check(NetworkManager.join("127.0.0.1","Guest",24660) == OK,"Client socket opens")

func _rules() -> void:
	SettingsManager.save_path = "user://test-settings.cfg"
	var original: float = SettingsManager.values.music
	check(SettingsManager.save_value("music",0.35) == OK,"Settings saved to disk")
	SettingsManager.values.music = 0.8
	SettingsManager._ready()
	check(is_equal_approx(SettingsManager.values.music,0.35),"Settings reloaded from disk")
	SettingsManager.values.music = original
	SettingsManager.save_path = SettingsManager.PATH
	SettingsManager.apply()
	DirAccess.remove_absolute("user://test-settings.cfg")
	for path: String in SceneRouter.SCREENS.values():
		check(load(path) is PackedScene,"Scene loads: " + path)
	var sim: BattleSimulation = BattleSimulation.new()
	sim.start(1,2,1,720)
	check(sim.map.nodes.size() == 12,"Twelve authored deployment nodes")
	check(sim.command(2,1,1,"build",{"node":0}) != "Accepted","Attacker cannot build")
	check(sim.command(1,1,1,"build",{"node":-1}) != "Accepted","Negative node rejected")
	check(sim.command(1,1,2,"build",{"node":12}) != "Accepted","Out-of-range node rejected")
	check(sim.command(1,1,3,"build",{"node":0}) == "Accepted","Legal tower purchase")
	check(sim.command(1,1,3,"build",{"node":0}) == "Accepted" and sim.state.wallets[1].gold == 180,"Duplicate purchase is idempotent")
	check(sim.command(1,1,4,"build",{"node":0}) != "Accepted" and sim.state.wallets[1].gold == 180,"Occupied node does not charge")
	check(sim.command(1,1,5,"build",{"node":1}) == "Accepted","Second legal tower")
	check(sim.command(1,1,6,"build",{"node":2}) != "Accepted" and sim.state.wallets[1].gold == 60,"Insufficient funds do not partially mutate")
	check(sim.command(1,0,7,"surrender",{}) != "Accepted","Stale match rejected")
	check(sim.command(2,1,2,"train",{"cost":-999,"damage":99999}) == "Accepted" and sim.state.wallets[2].gold == 230,"Host ignores claimed prices and damage")
	sim.step(1)
	check(sim.state.orders[0].remaining == 6 and sim.state.wallets[2].gold == 230,"Preparation freezes training and income")
	check(not sim.snapshot_for(1).wallets.has(2) and sim.snapshot_for(1).orders.is_empty(),"Opponent economy and orders private")
	sim.state.phase = "active"
	for tick: int in range(181):
		sim.step(1.0/30.0)
	check(sim.state.troops.size() == 3,"Training spawns squad after timer")
	check(sim.state.wallets[2].trained == 3,"Training statistics count units")
	sim.state.wallets[1].gold = 9999
	check(sim.command(1,1,8,"ability",{"node":0,"ability":"overclock"}) == "Accepted","First ability accepted")
	check(sim.command(1,1,9,"ability",{"node":0,"ability":"long_lens"}) == "Accepted","Second ability accepted")
	check(sim.command(1,1,10,"ability",{"node":0,"ability":"frost_script"}) != "Accepted","Third ability rejected")
	check(sim.command(1,1,11,"ability",{"node":0,"ability":"overclock"}) != "Accepted","Duplicate ability rejected")
	sim.state.wallets[2].gold = 9999
	check(sim.command(2,1,3,"ability",{"ability":"core_charge"}) == "Accepted","Troop blueprint upgrade accepted")
	check(sim.state.troops.values()[0].base_damage == 35,"Existing units retain frozen statistics")
	check(sim.command(2,1,4,"train",{}) == "Accepted" and sim.state.orders[0].stats.base_damage == 45,"Future order inherits ability snapshot")
	check(sim.command(2,1,5,"question",{}) == "Accepted","Question generation accepted")
	check(not sim.snapshot_for(2).questions[2].has("answers") and sim.snapshot_for(1).questions.is_empty(),"Answer keys and opponent questions not replicated")
	check(sim.command(2,1,6,"answer",{"answer":"var"}).begins_with("Correct"),"Host validates correct answer")
	var gold: int = sim.state.wallets[2].gold
	sim.command(2,1,6,"answer",{"answer":"var"})
	check(sim.state.wallets[2].gold == gold and sim.state.wallets[2].answered == 1,"Answer retry cannot award twice")
	var q: Array = QuestionRepository.questions.duplicate(true)
	check(QuestionRepository.validate_pack(q).is_empty(),"Bundled question pack valid: " + QuestionRepository.validate_pack(q))
	q[0].options[1] = q[0].options[0]
	check(not QuestionRepository.validate_pack(q).is_empty(),"Duplicate choices rejected")
	q = QuestionRepository.questions.duplicate(true)
	q[0].reward = -10
	check(not QuestionRepository.validate_pack(q).is_empty(),"Invalid reward rejected")
	sim.start(2,2,1,600)
	sim.state.phase = "active"
	sim.state.remaining = 1.0/30.0
	sim.state.base_hp = 35
	sim.state.troops[1] = {"id":1,"progress":sim.map.length-0.01,"hp":80.0,"speed":2.2,"base_damage":35,"slow_until":0.0,"abilities":[],"offset":0}
	sim.step(1.0/30.0)
	check(sim.state.outcome.winner == 2 and sim.state.base_hp == 0,"Lethal base contact wins on terminal tick")
	var frozen: Dictionary = sim.state.duplicate(true)
	sim.step(1)
	sim.command(2,2,1,"train",{})
	check(sim.state == frozen,"Terminal outcome and statistics immutable")
	sim.start(3,1,2,900)
	sim.state.phase = "active"
	sim.state.remaining = 0.01
	sim.step(1.0/30.0)
	check(sim.state.outcome.winner == 2,"Surviving defender wins timer")
	check(sim.state.orders.is_empty() and sim.state.towers.is_empty() and sim.state.wallets[1].gold == 300,"New match resets entities and resources")
	sim.start(4,1,2,10)
	check(sim.state.remaining == 600,"Production duration clamps to ten minutes")

func _capture(name_text: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	var error: Error = get_viewport().get_texture().get_image().save_png(output_dir + "/" + name_text + ".png")
	check(error == OK,"Screenshot " + name_text)

func _button(text: String) -> Button:
	for node: Node in get_tree().current_scene.find_children("*","Button",true,false):
		if (node as Button).text == text:
			return node as Button
	return null

func _ui() -> void:
	for width: int in [1366,1920]:
		DisplayServer.window_set_size(Vector2i(width,768 if width == 1366 else 1080))
		SceneRouter.go("menu")
		await get_tree().create_timer(0.4).timeout
		check(_button("PLAY") != null and _button("Quit") != null,"Starting controls exist")
		await _capture("menu-"+str(width))
		_button("Settings").pressed.emit()
		await get_tree().create_timer(0.3).timeout
		check(SceneRouter.current == "settings","Settings navigation")
		await _capture("settings-"+str(width))
		_button("Back").pressed.emit()
		await get_tree().create_timer(0.2).timeout
		_button("Developer").pressed.emit()
		await get_tree().create_timer(0.3).timeout
		check(SceneRouter.current == "developer","Developer navigation")
		_button("Validate").pressed.emit()
		await _capture("developer-"+str(width))
		_button("Back").pressed.emit()
		await get_tree().create_timer(0.2).timeout
		_button("PLAY").pressed.emit()
		await get_tree().create_timer(0.3).timeout
		check(SceneRouter.current == "browser","Play navigation")
		await _capture("browser-"+str(width))
		_button("Host Game").pressed.emit()
		await get_tree().create_timer(0.3).timeout
		check(SceneRouter.current == "lobby","Host navigation")
		await _capture("lobby-"+str(width))
		_button("Disconnect / Back").pressed.emit()
		await get_tree().create_timer(0.3).timeout
		check(not NetworkManager.active,"Disconnect clears session")
		_button("Back").pressed.emit()
		await get_tree().create_timer(0.2).timeout
	# Synthetic presentation fixtures are separate from the two-process test.
	NetworkManager.host("Presentation fixture","Host",24662)
	await get_tree().create_timer(0.2).timeout
	NetworkManager.attacker = 2
	NetworkManager.defender = 1
	SceneRouter.go("reveal")
	await get_tree().create_timer(0.3).timeout
	NetworkManager.phase = "loading"
	for width: int in [1366,1920]:
		DisplayServer.window_set_size(Vector2i(width,768 if width == 1366 else 1080))
		await get_tree().create_timer(0.2).timeout
		await _capture("reveal-"+str(width))
	NetworkManager.phase = "game"
	MatchState.begin(99,2,1,720)
	MatchState.simulation.command(1,99,1,"build",{"node":4})
	MatchState.simulation.command(2,99,1,"train",{})
	for tick: int in range(900):
		MatchState.simulation.step(1.0/30.0)
	NetworkManager.publish_state()
	SceneRouter.go("game")
	await get_tree().create_timer(0.5).timeout
	var screen: Control = get_tree().current_scene
	var field: BattlefieldView = screen.get("battlefield")
	field.select_node(4)
	for width: int in [1366,1920]:
		DisplayServer.window_set_size(Vector2i(width,768 if width == 1366 else 1080))
		await get_tree().create_timer(0.3).timeout
		await _capture("battle-defender-"+str(width))
		check(screen.get("feedback").get_global_rect().end.y <= screen.size.y,"Feedback stays inside viewport")
		field.change_zoom(-100)
		check(is_equal_approx(field.zoom,0.85),"Minimum zoom clamp")
		await _capture("battle-zoom-in-"+str(width))
		field.change_zoom(100)
		check(is_equal_approx(field.zoom,1.15),"Maximum zoom clamp")
		await _capture("battle-zoom-out-"+str(width))
		field.zoom = 1.0
	# Test both role HUDs and result treatments at both requested sizes.
	NetworkManager.attacker = 1
	NetworkManager.defender = 2
	MatchState.begin(100,1,2,720)
	NetworkManager.publish_state()
	SceneRouter.go("game")
	await get_tree().create_timer(0.3).timeout
	for width: int in [1366,1920]:
		DisplayServer.window_set_size(Vector2i(width,768 if width == 1366 else 1080))
		await get_tree().create_timer(0.3).timeout
		await _capture("battle-attacker-"+str(width))
	for winner: int in [1,2]:
		MatchState.begin(100+winner,1,2,720)
		MatchState.simulation.state.base_hp = 0 if winner == 1 else 1000
		MatchState.simulation.state.elapsed = 360.0 if winner == 1 else 720.0
		MatchState.simulation.finish(winner,"Time survived" if winner == 2 else "Code Core destroyed")
		MatchState.view.clear()
		NetworkManager.publish_state()
		SceneRouter.go("results")
		await get_tree().create_timer(0.3).timeout
		for width: int in [1366,1920]:
			DisplayServer.window_set_size(Vector2i(width,768 if width == 1366 else 1080))
			await get_tree().create_timer(0.3).timeout
			await _capture(("victory-" if winner == 1 else "defeat-")+str(width))
	SceneRouter.menu()
	await get_tree().create_timer(0.2).timeout
	check(MatchState.view.is_empty() and not NetworkManager.active,"Full navigation loop resets match")

func _process(delta: float) -> void:
	if finished or suite not in ["host","client"]:
		return
	if Time.get_ticks_msec()-start_time > 100000:
		check(false,"Integration timeout; phase="+NetworkManager.phase)
		done()
		return
	if not NetworkManager.active:
		return
	if NetworkManager.phase == "lobby" and NetworkManager.roster.size() == 2:
		if not NetworkManager.roster[NetworkManager.local_id()].ready:
			NetworkManager.set_ready(true)
			NetworkManager.set_ready(true)
		if suite == "host" and NetworkManager.can_start():
			NetworkManager.start_game()
		return
	if NetworkManager.phase == "reveal":
		if first_attacker == 0:
			first_attacker = NetworkManager.attacker
			print("ROLE match=1 attacker=%s defender=%s" % [NetworkManager.attacker,NetworkManager.defender])
		elif NetworkManager.match_id == 2 and not sent_actions.has("swapped"):
			check(NetworkManager.attacker != first_attacker,"Rematch swaps both roles")
			sent_actions.swapped = true
		return
	if MatchState.view.is_empty():
		return
	var id: int = MatchState.view.match_id
	if NetworkManager.phase == "game":
		var key: String = str(id)+"-initial"
		if not sent_actions.has(key):
			sent_actions[key] = true
			check(MatchState.view.attacker == NetworkManager.attacker,"Snapshot agrees with revealed roles")
			if id == 1:
				MatchState.request("train" if NetworkManager.local_id() == NetworkManager.attacker else "build",{} if NetworkManager.local_id() == NetworkManager.attacker else {"node":4})
		if id == 1 and NetworkManager.local_id() == NetworkManager.attacker:
			result_wait += delta
			if result_wait > 0.45:
				result_wait = 0
				MatchState.request("train")
		if suite == "host" and MatchState.simulation != null:
			# Accelerate only the test harness: execute the same fixed ticks, never alter outcomes.
			accelerated_time += delta*29.0
			while accelerated_time >= 1.0/30.0:
				accelerated_time -= 1.0/30.0
				MatchState.simulation.step(1.0/30.0)
	elif NetworkManager.phase == "results" and id not in seen_results:
		seen_results.append(id)
		print("RESULT " + JSON.stringify(MatchState.view))
		check(MatchState.view.outcome.reason == ("Code Core destroyed" if id == 1 else "Time survived"),"Host resolves expected match outcome")
		if id == 1:
			check(MatchState.view.wallets[MatchState.view.defender].built == 1,"Replicated defender tower purchase")
			check(MatchState.view.wallets[MatchState.view.attacker].trained >= 3,"Replicated training statistics")
			NetworkManager.vote_rematch()
			NetworkManager.vote_rematch()
		else:
			_finish_integration.call_deferred()

func _finish_integration() -> void:
	await get_tree().create_timer(0.5).timeout
	SceneRouter.menu()
	await get_tree().create_timer(0.2).timeout
	check(not NetworkManager.active and MatchState.view.is_empty(),"Integration menu cleanup")
	done()

func _until(predicate: Callable, seconds: float = 15.0) -> bool:
	var deadline: int = Time.get_ticks_msec()+int(seconds*1000)
	while not predicate.call() and Time.get_ticks_msec() < deadline:
		await get_tree().create_timer(0.05).timeout
	return predicate.call()

func _faults() -> void:
	if suite == "fault-host":
		check(NetworkManager.host("Failure tests","Host",24661) == OK,"Fault host opens")
		NetworkManager.start_game()
		check(NetworkManager.phase == "lobby","Start without second player rejected")
		check(await _until(func() -> bool: return NetworkManager.roster.size() == 2),"First guest accepted")
		NetworkManager.set_ready(true)
		check(await _until(func() -> bool: return NetworkManager.roster.size() == 1),"Lobby disconnect removes guest")
		check(not NetworkManager.roster[1].ready and NetworkManager.phase == "lobby","Lobby disconnect clears ready")
		check(await _until(func() -> bool: return NetworkManager.roster.size() == 2),"Guest can return to lobby")
		NetworkManager.start_game()
		check(NetworkManager.phase == "lobby","Start before both ready rejected")
		NetworkManager.set_ready(true)
		check(await _until(func() -> bool: return NetworkManager.can_start()),"Both peers ready after reconnect")
		NetworkManager.set_duration(660)
		check(NetworkManager.roster.values().all(func(p: Dictionary) -> bool: return not p.ready),"Duration change resets both ready flags")
		NetworkManager.set_ready(true)
		check(await _until(func() -> bool: return NetworkManager.can_start()),"Ready after setting change")
		NetworkManager.start_game()
		check(await _until(func() -> bool: return NetworkManager.phase == "results",20),"Match disconnect reaches results")
		check(MatchState.view.outcome.winner == 1 and MatchState.view.outcome.reason == "Opponent disconnected","Guest disconnect awards host exactly one result")
	elif suite == "fault-client":
		check(NetworkManager.join("127.0.0.1","Guest",24661) == OK,"Fault client joins")
		check(await _until(func() -> bool: return NetworkManager.phase == "lobby"),"Fault client handshake")
		await get_tree().create_timer(1.0).timeout
		NetworkManager.leave()
		await get_tree().create_timer(0.7).timeout
		NetworkManager.join("127.0.0.1","Guest",24661)
		check(await _until(func() -> bool: return NetworkManager.phase == "lobby"),"Client rejoins after lobby exit")
		await get_tree().create_timer(1.0).timeout
		var deadline: int = Time.get_ticks_msec()+15000
		while NetworkManager.phase == "lobby" and Time.get_ticks_msec() < deadline:
			NetworkManager.set_ready(true)
			await get_tree().create_timer(0.1).timeout
		check(await _until(func() -> bool: return NetworkManager.phase == "game"),"Fault client reaches match")
		NetworkManager.leave()
		check(MatchState.view.is_empty(),"Leaving match clears local simulation")
		await get_tree().create_timer(0.7).timeout
	elif suite == "fault-full":
		NetworkManager.join("127.0.0.1","Third",24661)
		check(await _until(func() -> bool: return not NetworkManager.active),"Third connection rejected")
		check(NetworkManager.status.contains("full") or NetworkManager.status.contains("started"),"Full lobby gives explicit reason")
	elif suite == "fault-mismatch":
		QuestionRepository.questions[0].reward = 26
		NetworkManager.join("127.0.0.1","Mismatch",24661)
		check(await _until(func() -> bool: return not NetworkManager.active),"Mismatched content rejected")
		check(NetworkManager.status.contains("Incompatible"),"Mismatch gives explicit reason")
	elif suite == "fault-timeout":
		NetworkManager.join("127.0.0.1","Nobody",24999)
		check(await _until(func() -> bool: return not NetworkManager.active),"Unreachable host times out")
		check(NetworkManager.status.contains("timed out") or NetworkManager.status.contains("failed"),"Connection failure feedback")
	elif suite == "fault-exit-host":
		NetworkManager.host("Exit test","Host",24662)
		check(await _until(func() -> bool: return NetworkManager.roster.size() == 2),"Exit test client accepted")
		await get_tree().create_timer(0.5).timeout
		NetworkManager.leave()
	elif suite == "fault-exit-client":
		NetworkManager.join("127.0.0.1","Guest",24662)
		check(await _until(func() -> bool: return NetworkManager.phase == "lobby"),"Exit test handshake")
		check(await _until(func() -> bool: return not NetworkManager.active),"Client detects host exit")
		check(NetworkManager.status.contains("no verified outcome"),"Host exit does not fabricate a winner")
