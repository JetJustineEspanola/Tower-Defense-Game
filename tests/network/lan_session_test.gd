extends SceneTree

const SESSION = preload("res://scripts/network/lan_session.gd")
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var host_root := Node.new()
	var lan_scene: PackedScene = load("res://scenes/network/lan_match.tscn")
	_expect(lan_scene != null, "LAN match scene loads")
	if lan_scene != null:
		var match_node: Node = lan_scene.instantiate()
		_expect(match_node.get_meta("transport", "") == "lan", "LAN match selects local session")
		_expect(match_node.get_script().resource_path == "res://scripts/network/online_match.gd", "LAN match reuses online gameplay controller")
		match_node.free()
	host_root.name = "Host"
	root.add_child(host_root)
	var guest_root := Node.new()
	guest_root.name = "Guest"
	root.add_child(guest_root)
	set_multiplayer(MultiplayerAPI.create_default_interface(), host_root.get_path())
	set_multiplayer(MultiplayerAPI.create_default_interface(), guest_root.get_path())
	var host: Node = SESSION.new()
	host.name = "Session"
	host_root.add_child(host)
	var guest: Node = SESSION.new()
	guest.name = "Session"
	guest_root.add_child(guest)
	await process_frame
	var deck: Dictionary = preload("res://scripts/questions/deck_store.gd").active()
	_expect(host.create_room("Host", deck), "host opens an ENet room")
	var discovered: Array[Dictionary] = []
	guest.rooms_found.connect(func(rooms: Array[Dictionary]): discovered.assign(rooms))
	guest.discover()
	var discovery_deadline := Time.get_ticks_msec() + 2500
	while Time.get_ticks_msec() < discovery_deadline and discovered.is_empty(): await process_frame
	_expect(not discovered.is_empty(), "guest discovers host advertisement")
	var errors: Array[String] = []
	guest.status_changed.connect(func(message: String): errors.append(message))
	_expect(not guest.join_room("wrong-host", "Guest"), "invalid host address is rejected")
	_expect(not errors.is_empty() and errors[-1].contains("IPv4"), "invalid host address has a clear error")
	_expect(guest.join_room("127.0.0.1", "Guest"), "guest starts direct-IP join")
	for i in 120:
		await process_frame
		if guest.room.get("players", []).size() == 2: break
	_expect(host.room.get("players", []).size() == 2, "host sees two players")
	_expect(guest.room.get("players", []).size() == 2, "guest sees two players")
	var third_root := Node.new()
	third_root.name = "Third"
	root.add_child(third_root)
	set_multiplayer(MultiplayerAPI.create_default_interface(), third_root.get_path())
	var third: Node = SESSION.new()
	third.name = "Session"
	third_root.add_child(third)
	var full_messages: Array[String] = []
	third.status_changed.connect(func(message: String): full_messages.append(message))
	third.room_closed.connect(func(message: String): full_messages.append(message))
	third.join_room("127.0.0.1", "Third")
	var full_deadline := Time.get_ticks_msec() + 1500
	while Time.get_ticks_msec() < full_deadline and not full_messages.any(func(message: String): return message.contains("full")):
		await process_frame
	_expect(full_messages.any(func(message: String): return message.contains("full")), "full room gives a clear error")
	third.leave()
	guest.set_ready(true)
	for i in 30: await process_frame
	_expect(host.room.get("players", [])[1].get("ready", false), "guest readiness reaches host")
	var old_revision: int = int(host.room.deck_revision)
	host.update_deck(deck)
	guest._server_message.rpc_id(1, {"type": "ready", "ready": true, "revision": old_revision})
	for i in 30: await process_frame
	_expect(not host.room.players[1].ready, "stale readiness cannot approve a changed deck")
	guest.set_ready(true)
	for i in 30: await process_frame
	host.set_ready(true)
	host.start_match()
	for i in 30: await process_frame
	_expect(not host.match_info.is_empty() and not guest.match_info.is_empty(), "both peers receive match info")
	_expect(host.match_info.get("role", "") != guest.match_info.get("role", ""), "roles differ")
	var commands: Array[Dictionary] = []
	var states: Array[Dictionary] = []
	var beginnings: Array[int] = []
	host.command_received.connect(func(message: Dictionary): commands.append(message))
	guest.state_received.connect(func(state: Dictionary): states.append(state))
	host.match_begin.connect(func(): beginnings.append(1))
	guest.match_begin.connect(func(): beginnings.append(2))
	host.loaded()
	guest.loaded()
	for i in 20: await process_frame
	_expect(beginnings.size() == 2, "match starts after both peers load")
	guest.command("train", {"index": 0})
	for i in 20: await process_frame
	_expect(commands.size() == 1 and commands[0].get("role") == guest.match_info.role, "guest command reaches host with assigned role")
	host.snapshot({"position": [1, 2, 3]})
	for i in 20: await process_frame
	_expect(states.size() == 1 and states[0].get("position") == [1, 2, 3], "host snapshot reaches guest")
	var first_host_role: String = host.match_info.role
	var first_match_id: String = host.match_info.match_id
	host.end_match("attacker")
	for i in 10: await process_frame
	host.rematch()
	guest.rematch()
	for i in 30: await process_frame
	_expect(host.match_info.role != first_host_role and guest.match_info.role == first_host_role, "rematch swaps roles")
	guest._server_message.rpc_id(1, {"type": "rematch", "match_id": first_match_id})
	for i in 20: await process_frame
	_expect(host.get("_rematch").is_empty(), "stale rematch does not count in the next match")
	guest.leave()
	for i in 30: await process_frame
	_expect(host.room.get("players", []).size() == 1, "host sees guest departure")
	var guest_closed: Array[String] = []
	guest.room_closed.connect(func(message: String): guest_closed.append(message))
	_expect(guest.join_room("127.0.0.1", "Guest"), "guest can rejoin after a drop")
	for i in 60:
		await process_frame
		if guest.room.get("players", []).size() == 2: break
	guest._server_message.rpc_id(1, {"type": "hello", "build": "incompatible", "name": "Guest"})
	var mismatch_deadline := Time.get_ticks_msec() + 1500
	while Time.get_ticks_msec() < mismatch_deadline and not guest_closed.any(func(message: String): return message.contains("Incompatible")):
		await process_frame
	_expect(guest_closed.any(func(message: String): return message.contains("Incompatible")), "incompatible build gives a clear error")
	_expect(guest.join_room("127.0.0.1", "Guest"), "guest can rejoin after version rejection")
	for i in 60:
		await process_frame
		if guest.room.get("players", []).size() == 2: break
	host.leave()
	for i in 30: await process_frame
	_expect(not guest_closed.is_empty() and guest_closed[-1].contains("host disconnected"), "guest sees host departure")
	if failures == 0:
		print("PASS: LAN host, direct IP, readiness, start, disconnect")
		quit(0)
	else:
		quit(1)

func _expect(condition: bool, message: String) -> void:
	if condition: return
	failures += 1
	push_error("FAIL: " + message)
