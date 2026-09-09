extends Node

signal lobby_changed
signal status_changed(message: String)
signal reveal_changed
const DEFAULT_PORT: int = 24560
var active: bool = false
var roster: Dictionary = {}
var phase: String = "offline"
var lobby_name: String = "Arcane Crossing"
var display_name: String = "Player"
var duration: int = 720
var game_port: int = DEFAULT_PORT
var host_address: String = ""
var match_id: int = 0
var attacker: int = 0
var defender: int = 0
var reveal_left: float = 5.0
var discovery: LobbyDiscovery
var status: String = ""
var rematch_votes: Array[int] = []
var scene_loaded: Array[int] = []
var handshake_deadlines: Dictionary = {}
var command_rates: Dictionary = {}
var connection_deadline: int = 0
var phase_deadline: int = 0
var reveal_accumulator: float = 0.0

func _ready() -> void:
	discovery = LobbyDiscovery.new()
	add_child(discovery)
	multiplayer.connected_to_server.connect(_connected)
	multiplayer.connection_failed.connect(func() -> void: _lost("Connection failed. Check IP, port, firewall, or full lobby."))
	multiplayer.server_disconnected.connect(func() -> void: _lost("Connection lost. Match interrupted; no verified outcome."))
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func is_host() -> bool:
	return active and multiplayer.is_server()

func local_id() -> int:
	return multiplayer.get_unique_id() if active else 1

func say(message: String) -> void:
	status = message
	status_changed.emit(message)

func host(name_text: String, player: String, port: int = DEFAULT_PORT) -> Error:
	leave()
	if port < 1024 or port > 65535:
		say("Port must be 1024 to 65535.")
		return ERR_INVALID_PARAMETER
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(port, 8, 3)
	if error != OK:
		say("Cannot host on UDP port %s (error %s). Choose another port." % [port, error])
		return error
	multiplayer.multiplayer_peer = peer
	active = true
	phase = "lobby"
	game_port = port
	lobby_name = name_text.strip_edges().left(40)
	if lobby_name.is_empty():
		lobby_name = "Arcane Crossing"
	display_name = player.strip_edges().left(24)
	if display_name.is_empty():
		display_name = "Host"
	roster = {1:{"name":display_name,"ready":false}}
	discovery.host()
	say("Hosting. " + discovery.error_text)
	SceneRouter.go("lobby")
	return OK

func join(address: String, player: String, port: int = DEFAULT_PORT) -> Error:
	if not address.is_valid_ip_address() or address.contains(":") or port < 1024 or port > 65535:
		say("Enter a valid IPv4 address and a port from 1024 to 65535.")
		return ERR_INVALID_PARAMETER
	leave()
	display_name = player.strip_edges().left(24)
	host_address = address
	game_port = port
	if display_name.is_empty():
		display_name = "Guest"
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(address, port, 3)
	if error != OK:
		say("Could not create connection (%s)." % error)
		return error
	multiplayer.multiplayer_peer = peer
	active = true
	phase = "connecting"
	connection_deadline = Time.get_ticks_msec() + 10000
	say("Connecting to %s:%s..." % [address, port])
	return OK

func leave() -> void:
	discovery.stop()
	active = false
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	roster.clear()
	phase = "offline"
	attacker = 0
	defender = 0
	rematch_votes.clear()
	scene_loaded.clear()
	handshake_deadlines.clear()
	command_rates.clear()
	connection_deadline = 0
	host_address = ""
	MatchState.reset()

func _connected() -> void:
	_hello.rpc_id(1, AppState.PROTOCOL, AppState.BUILD, AppState.content_hash(), display_name)

func _peer_connected(peer: int) -> void:
	if is_host():
		handshake_deadlines[peer] = Time.get_ticks_msec() + 5000
		var enet: ENetMultiplayerPeer = multiplayer.multiplayer_peer as ENetMultiplayerPeer
		enet.get_peer(peer).set_timeout(8, 3000, 10000)

@rpc("any_peer", "call_remote", "reliable", 0)
func _hello(protocol: int, build: String, content: String, player: String) -> void:
	if not is_host():
		return
	var sender: int = multiplayer.get_remote_sender_id()
	if roster.has(sender):
		return
	if phase != "lobby" or roster.size() >= 2:
		_rejected.rpc_id(sender,"Lobby full or match already started.")
		return
	if protocol != AppState.PROTOCOL or build != AppState.BUILD or content != AppState.content_hash():
		_rejected.rpc_id(sender,"Incompatible build or question pack. Both players need identical content.")
		return
	if player.is_empty() or player.length() > 24:
		_rejected.rpc_id(sender,"Invalid display name.")
		return
	handshake_deadlines.erase(sender)
	roster[sender] = {"name":player,"ready":false}
	_broadcast_lobby()

@rpc("authority", "call_remote", "reliable", 0)
func _rejected(message: String) -> void:
	_lost(message)

func _lost(message: String) -> void:
	leave()
	AppState.notice = message
	say(message)
	SceneRouter.go("browser")

func _peer_disconnected(peer: int) -> void:
	if not is_host():
		return
	handshake_deadlines.erase(peer)
	if not roster.has(peer):
		return
	roster.erase(peer)
	rematch_votes.clear()
	if MatchState.simulation != null:
		MatchState.simulation.finish(1, "Opponent disconnected")
		publish_state()
	else:
		phase = "lobby"
		scene_loaded.clear()
		roster[1].ready = false
		SceneRouter.go("lobby")
	say("Opponent disconnected.")
	_broadcast_lobby()

func set_ready(value: bool) -> void:
	if is_host():
		_ready_request_local(1, value)
	elif active:
		_ready_request.rpc_id(1, value)

@rpc("any_peer", "call_remote", "reliable", 0)
func _ready_request(value: bool) -> void:
	if is_host():
		_ready_request_local(multiplayer.get_remote_sender_id(), value)

func _ready_request_local(peer: int, value: bool) -> void:
	if phase == "lobby" and roster.has(peer):
		roster[peer].ready = value
		_broadcast_lobby()

func set_duration(seconds: int) -> void:
	if is_host() and phase == "lobby":
		duration = clampi(seconds,600,900)
		for peer: int in roster:
			roster[peer].ready = false
		_broadcast_lobby()

func can_start() -> bool:
	return phase == "lobby" and roster.size() == 2 and roster.values().all(func(player: Dictionary) -> bool: return player.ready)

func start_game(swap: bool = false) -> void:
	if not is_host() or (not swap and not can_start()) or (swap and (phase != "results" or rematch_votes.size() != 2)):
		say("Both players must be connected and ready.")
		return
	var guest: int = int(roster.keys().filter(func(id: int) -> bool: return id != 1)[0])
	if swap:
		var previous: int = attacker
		attacker = defender
		defender = previous
	else:
		attacker = 1 if randi() % 2 == 0 else guest
		defender = guest if attacker == 1 else 1
	match_id += 1
	rematch_votes.clear()
	scene_loaded.clear()
	MatchState.reset()
	phase = "loading"
	phase_deadline = Time.get_ticks_msec() + 30000
	_begin_reveal.rpc(match_id, attacker, defender)

@rpc("authority", "call_local", "reliable", 0)
func _begin_reveal(id: int, attacker_id: int, defender_id: int) -> void:
	match_id = id
	attacker = attacker_id
	defender = defender_id
	phase = "loading"
	reveal_left = 5.0
	MatchState.reset()
	SceneRouter.go("reveal")

func acknowledge_scene() -> void:
	if is_host():
		_loaded_local(1)
	else:
		_loaded.rpc_id(1, match_id)

@rpc("any_peer", "call_remote", "reliable", 0)
func _loaded(id: int) -> void:
	if is_host() and id == match_id:
		_loaded_local(multiplayer.get_remote_sender_id())

func _loaded_local(peer: int) -> void:
	if phase != "loading" or not roster.has(peer) or peer in scene_loaded:
		return
	scene_loaded.append(peer)
	if scene_loaded.size() == 2:
		phase = "reveal"
		reveal_left = 5.0
		reveal_accumulator = 0.0
		_reveal_clock.rpc(5.0)

@rpc("authority", "call_local", "reliable", 0)
func _reveal_clock(seconds: float) -> void:
	phase = "reveal"
	reveal_left = seconds
	reveal_changed.emit()

@rpc("authority", "call_local", "reliable", 0)
func _enter_battle() -> void:
	phase = "game"
	SceneRouter.go("game")

func _broadcast_lobby() -> void:
	for peer: int in roster:
		if peer != 1:
			_lobby_state.rpc_id(peer,roster,lobby_name,duration,phase,game_port)
	lobby_changed.emit()

@rpc("authority", "call_remote", "reliable", 0)
func _lobby_state(players: Dictionary, title: String, seconds: int, session_phase: String, port: int) -> void:
	roster = players
	lobby_name = title
	duration = seconds
	game_port = port
	connection_deadline = 0
	phase = session_phase
	lobby_changed.emit()
	if phase == "lobby" and SceneRouter.current != "lobby":
		SceneRouter.go("lobby")

func send_command(id: int, seq: int, action: String, payload: Dictionary) -> void:
	if is_host():
		_command_local(1,id,seq,action,payload)
	elif active:
		_command.rpc_id(1,id,seq,action,payload)

@rpc("any_peer", "call_remote", "reliable", 0)
func _command(id: int, seq: int, action: String, payload: Dictionary) -> void:
	if is_host():
		_command_local(multiplayer.get_remote_sender_id(),id,seq,action,payload)

func _command_local(peer: int, id: int, seq: int, action: String, payload: Dictionary) -> void:
	if not roster.has(peer) or MatchState.simulation == null:
		return
	var now: int = Time.get_ticks_msec()
	var rate: Dictionary = command_rates.get(peer,{"time":now,"count":0})
	if now - int(rate.time) >= 1000:
		rate = {"time":now,"count":0}
	rate.count += 1
	command_rates[peer] = rate
	var message: String
	if int(rate.count) > 40 or action.length() > 32 or var_to_bytes(payload).size() > 2048 or seq <= 0:
		message = "Command rate or size limit exceeded."
	else:
		message = MatchState.simulation.command(peer,id,seq,action,payload)
	if peer == 1:
		MatchState.command_result.emit(seq,message)
	else:
		_command_ack.rpc_id(peer,seq,message)
	publish_state()

@rpc("authority", "call_remote", "reliable", 0)
func _command_ack(seq: int, message: String) -> void:
	MatchState.command_result.emit(seq,message)

func publish_state() -> void:
	if not is_host() or MatchState.simulation == null:
		return
	if MatchState.simulation.state.phase == "results":
		phase = "results"
	for peer: int in roster:
		var snapshot: Dictionary = MatchState.simulation.snapshot_for(peer)
		if peer == 1:
			MatchState.receive(snapshot)
		else:
			_snapshot.rpc_id(peer,snapshot)

@rpc("authority", "call_remote", "reliable", 1)
func _snapshot(snapshot: Dictionary) -> void:
	if int(snapshot.match_id) != match_id:
		return
	MatchState.receive(snapshot)
	if snapshot.phase == "results":
		phase = "results"

func vote_rematch() -> void:
	if is_host():
		_rematch_local(1)
	elif active:
		_rematch.rpc_id(1,match_id)

@rpc("any_peer", "call_remote", "reliable", 0)
func _rematch(id: int) -> void:
	if is_host() and id == match_id:
		_rematch_local(multiplayer.get_remote_sender_id())

func _rematch_local(peer: int) -> void:
	if phase != "results" or not roster.has(peer) or peer in rematch_votes:
		return
	rematch_votes.append(peer)
	if rematch_votes.size() == 2:
		start_game(true)

func _process(delta: float) -> void:
	if not active:
		return
	var now: int = Time.get_ticks_msec()
	if connection_deadline > 0 and now > connection_deadline:
		_lost("Connection timed out. Check the address, port, firewall, and lobby availability.")
		return
	if not is_host():
		return
	for peer: int in handshake_deadlines.keys():
		if now > int(handshake_deadlines[peer]):
			multiplayer.multiplayer_peer.disconnect_peer(peer)
			handshake_deadlines.erase(peer)
	if phase == "loading" and now > phase_deadline:
		phase = "lobby"
		for peer: int in roster:
			roster[peer].ready = false
		say("Loading timed out; ready again to retry.")
		_broadcast_lobby()
		SceneRouter.go("lobby")
	if phase == "reveal":
		reveal_left = maxf(0.0,reveal_left-delta)
		reveal_accumulator += delta
		if reveal_accumulator >= 0.1:
			reveal_accumulator = 0.0
			_reveal_clock.rpc(reveal_left)
		if reveal_left <= 0.0:
			MatchState.begin(match_id,attacker,defender,duration)
			_enter_battle.rpc()
			publish_state()
