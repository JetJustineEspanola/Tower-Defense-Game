extends Node
## Local, two-player transport for the existing host-authoritative match controller.
signal room_changed(room: Dictionary)
signal rooms_found(rooms: Array[Dictionary])
signal status_changed(message: String)
signal room_closed(message: String)
signal match_started
signal match_begin
signal command_received(message: Dictionary)
signal state_received(state: Dictionary)
signal match_ended(winner: String)
signal rematch_waiting(players: int)

const BUILD := "codeborn-match-1"
const GAME_PORT := 42150
const DISCOVERY_PORT := 42151
const TIMEOUT_MS := 8000
const ACTIONS := ["train", "place", "troop_upgrade", "tower_upgrade", "tower_priority", "troop_priority", "troop_auto", "siege", "guard", "answer", "next_question", "boost"]
const DECK_STORE = preload("res://scripts/questions/deck_store.gd")
var room: Dictionary = {}
var match_info: Dictionary = {}
var player_id := ""
var request_counter := 0
var sent_sequence := 0
var received_sequence := -1
var _hosting := false
var _connecting := false
var _connected := false
var _connect_started := 0
var _guest_peer := 0
var _host_name := ""
var _guest_name := ""
var _deck: Dictionary = {}
var _match_counter := 0
var _loaded: Dictionary = {}
var _rematch: Dictionary = {}
var _last_requests: Dictionary = {}
var _known_rooms: Dictionary = {}
var _discovery: PacketPeerUDP
var _advertiser: PacketPeerUDP
var _advertise_elapsed := 0.0
var _discovering := false
var _rejection := ""
var _begun := false
var _ended := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_host)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_host_disconnected)

func create_room(name: String, deck: Dictionary) -> bool:
	leave()
	if not DECK_STORE.valid(deck).is_empty():
		status_changed.emit("The selected Astral deck is invalid.")
		return false
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_server(GAME_PORT, 2)
	if error != OK:
		status_changed.emit("Could not host on port %d. Close another room or check firewall access." % GAME_PORT)
		return false
	multiplayer.multiplayer_peer = peer
	_hosting = true
	_connected = true
	player_id = "1"
	_host_name = _clean_name(name)
	_deck = deck.duplicate(true)
	room = {"host_id": "1", "deck": _deck, "deck_revision": 1, "players": [_member("1", _host_name, true, false)]}
	_sync_room()
	_start_advertising()
	return true

func join_room(address: String, name: String) -> bool:
	leave()
	address = address.strip_edges()
	if not _valid_ipv4(address):
		status_changed.emit("Enter the host's local IPv4 address, such as 192.168.1.2.")
		return false
	var peer := ENetMultiplayerPeer.new()
	var error := peer.create_client(address, GAME_PORT)
	if error != OK:
		status_changed.emit("Could not start the LAN connection. Check the host IP and Wi-Fi.")
		return false
	multiplayer.multiplayer_peer = peer
	_guest_name = _clean_name(name)
	_rejection = ""
	_connecting = true
	_connect_started = Time.get_ticks_msec()
	status_changed.emit("Connecting to %s..." % address)
	return true

func discover() -> void:
	if _hosting: return
	if _discovery == null:
		_discovery = PacketPeerUDP.new()
		if _discovery.bind(DISCOVERY_PORT, "0.0.0.0") != OK:
			_discovery = null
			status_changed.emit("Discovery is unavailable. Enter the host IP address instead.")
			return
	_discovering = true
	_known_rooms.clear()
	var empty_rooms: Array[Dictionary] = []
	rooms_found.emit(empty_rooms)

func stop_discovery() -> void:
	_discovering = false
	if _discovery != null:
		_discovery.close()
		_discovery = null

func _process(delta: float) -> void:
	if _connecting and Time.get_ticks_msec() - _connect_started > TIMEOUT_MS:
		leave()
		status_changed.emit("Host unreachable. Check the IP, shared Wi-Fi or hotspot, and firewall.")
	if _hosting and _advertiser != null:
		_advertise_elapsed += delta
		if _advertise_elapsed >= 1.0:
			_advertise_elapsed = 0.0
			_advertise()
	if _discovering and _discovery != null:
		var changed := false
		while _discovery.get_available_packet_count() > 0:
			var raw: Variant = JSON.parse_string(_discovery.get_packet().get_string_from_utf8())
			var address := _discovery.get_packet_ip()
			if raw is Dictionary and raw.get("build") == BUILD and raw.get("type") == "codeborn_lan":
				var previous: Dictionary = _known_rooms.get(address, {})
				changed = changed or previous.is_empty() or previous.get("name") != raw.get("name") or previous.get("players") != raw.get("players")
				_known_rooms[address] = {"id": address, "name": str(raw.get("name", "LAN Room")), "players": int(raw.get("players", 1)), "seen": Time.get_ticks_msec()}
		for address in _known_rooms.keys():
			if Time.get_ticks_msec() - int(_known_rooms[address].seen) > 3500:
				_known_rooms.erase(address)
				changed = true
		if changed:
			var visible_rooms: Array[Dictionary] = []
			for value in _known_rooms.values():
				visible_rooms.append({"id": value.id, "name": value.name, "players": value.players})
			rooms_found.emit(visible_rooms)

func _start_advertising() -> void:
	_advertiser = PacketPeerUDP.new()
	_advertiser.set_broadcast_enabled(true)
	_advertiser.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	_advertise()

func _advertise() -> void:
	var data := {"type": "codeborn_lan", "build": BUILD, "name": _host_name + "'s room", "players": room.get("players", []).size()}
	_advertiser.put_packet(JSON.stringify(data).to_utf8_buffer())

func _member(id: String, name: String, host: bool, ready: bool) -> Dictionary:
	return {"id": id, "name": name, "host": host, "ready": ready}

func _clean_name(name: String) -> String:
	name = name.strip_edges().substr(0, 20)
	return name if not name.is_empty() else "Player"

func _valid_ipv4(address: String) -> bool:
	var parts := address.split(".")
	if parts.size() != 4: return false
	for part in parts:
		if part.is_empty() or not part.is_valid_int(): return false
		if int(part) < 0 or int(part) > 255: return false
	return true

func _peer_connected(id: int) -> void:
	if not _hosting: return
	if _guest_peer != 0 or not match_info.is_empty():
		_client_message.rpc_id(id, {"type": "error", "message": "This LAN room is full or already playing."})
		_disconnect_later(id)
		return
	_guest_peer = id

func _disconnect_later(id: int) -> void:
	await get_tree().create_timer(0.25).timeout
	if _hosting and multiplayer.multiplayer_peer != null and multiplayer.get_peers().has(id):
		multiplayer.multiplayer_peer.disconnect_peer(id)

func _peer_disconnected(id: int) -> void:
	if not _hosting or id != _guest_peer: return
	_guest_peer = 0
	if not match_info.is_empty():
		room_closed.emit("The other player disconnected. The LAN match has ended.")
		match_info.clear()
	room.players.resize(1)
	room.players[0].ready = false
	_loaded.clear()
	_rematch.clear()
	_sync_room()
	status_changed.emit("Guest disconnected. Waiting for another player.")

func _connected_to_host() -> void:
	_connected = true
	player_id = str(multiplayer.get_unique_id())
	_server_message.rpc_id(1, {"type": "hello", "build": BUILD, "name": _guest_name})

func _connection_failed() -> void:
	leave()
	status_changed.emit("Host unreachable. Check the IP, shared Wi-Fi or hotspot, and firewall.")

func _host_disconnected() -> void:
	var message := _rejection if not _rejection.is_empty() else "The host disconnected. Return to the LAN lobby to join another room."
	leave()
	room_closed.emit(message)

@rpc("any_peer", "reliable")
func _server_message(message: Dictionary) -> void:
	if not _hosting: return
	var sender := multiplayer.get_remote_sender_id()
	if sender == 0 or sender != _guest_peer: return
	match str(message.get("type", "")):
		"hello":
			if message.get("build") != BUILD or not match_info.is_empty():
				_client_message.rpc_id(sender, {"type": "error", "message": "Incompatible game version or room already started."})
				_disconnect_later(sender)
				return
			if room.players.size() == 2: return
			room.players = [room.players[0], _member(str(sender), _clean_name(str(message.get("name", "Player"))), false, false)]
			_sync_room()
		"ready":
			if room.players.size() == 2 and int(message.get("revision", -1)) == int(room.deck_revision):
				room.players[1].ready = bool(message.get("ready", false))
				_sync_room()
		"loaded":
			if message.get("match_id") == match_info.get("match_id"):
				_loaded[str(sender)] = true
				_maybe_begin()
		"command":
			_receive_command(sender, message)
		"rematch":
			if _ended and message.get("match_id") == match_info.get("match_id"):
				_rematch[str(sender)] = true
				_maybe_rematch()

@rpc("authority", "reliable")
func _client_message(message: Dictionary) -> void:
	if _hosting: return
	match str(message.get("type", "")):
		"room":
			_connecting = false
			var state: Dictionary = message.get("room", {})
			if not DECK_STORE.valid(state.get("deck", {})).is_empty():
				leave()
				room_closed.emit("The host's Astral deck is invalid.")
				return
			room = state
			room_changed.emit(room)
		"match_start":
			match_info = message.get("info", {})
			_ended = false
			request_counter = 0
			received_sequence = -1
			match_started.emit()
		"begin":
			if message.get("match_id") == match_info.get("match_id"): match_begin.emit()
		"state":
			if message.get("match_id") == match_info.get("match_id") and int(message.get("seq", -1)) > received_sequence:
				received_sequence = int(message.seq)
				state_received.emit(message.get("state", {}))
		"end":
			if message.get("match_id") == match_info.get("match_id"):
				_ended = true
				match_ended.emit(str(message.get("winner", "")))
		"rematch_wait": rematch_waiting.emit(int(message.get("players", 0)))
		"error":
			_rejection = str(message.get("message", "LAN request rejected."))
			status_changed.emit(_rejection)

func _sync_room() -> void:
	room_changed.emit(room)
	if _guest_peer != 0 and room.players.size() == 2:
		_client_message.rpc_id(_guest_peer, {"type": "room", "room": room})

func is_host() -> bool:
	return _hosting

func set_ready(value: bool) -> void:
	if _hosting and not room.is_empty():
		room.players[0].ready = value
		_sync_room()
	elif _connected:
		_server_message.rpc_id(1, {"type": "ready", "ready": value, "revision": room.get("deck_revision", -1)})

func update_deck(deck: Dictionary) -> void:
	if not _hosting or not match_info.is_empty(): return
	if not DECK_STORE.valid(deck).is_empty():
		status_changed.emit("The selected Astral deck is invalid.")
		return
	_deck = deck.duplicate(true)
	room.deck = _deck
	room.deck_revision = int(room.deck_revision) + 1
	for member in room.players: member.ready = false
	_sync_room()

func start_match() -> void:
	if not _hosting or room.players.size() != 2: return
	if not room.players[0].ready or not room.players[1].ready: return
	_start_match(false)

func _start_match(swapped: bool) -> void:
	_match_counter += 1
	var match_id := "%d-%d" % [Time.get_ticks_msec(), _match_counter]
	var host_role := "attacker" if randi() % 2 == 0 else "defender"
	if swapped: host_role = "defender" if match_info.get("role") == "attacker" else "attacker"
	var guest_role := "defender" if host_role == "attacker" else "attacker"
	_loaded.clear()
	_rematch.clear()
	_last_requests.clear()
	_begun = false
	_ended = false
	request_counter = 0
	sent_sequence = 0
	match_info = {"match_id": match_id, "role": host_role, "deck": _deck}
	_client_message.rpc_id(_guest_peer, {"type": "match_start", "info": {"match_id": match_id, "role": guest_role, "deck": _deck}})
	match_started.emit()

func loaded() -> void:
	if match_info.is_empty(): return
	if _hosting:
		_loaded["1"] = true
		_maybe_begin()
	else:
		_server_message.rpc_id(1, {"type": "loaded", "match_id": match_info.match_id})

func _maybe_begin() -> void:
	if _begun or not _loaded.has("1") or not _loaded.has(str(_guest_peer)): return
	_begun = true
	_client_message.rpc_id(_guest_peer, {"type": "begin", "match_id": match_info.match_id})
	match_begin.emit()

func command(action: String, data: Dictionary) -> void:
	if match_info.is_empty(): return
	request_counter += 1
	var message := {"match_id": match_info.match_id, "request_id": request_counter, "action": action, "data": data}
	if _hosting: _receive_command(1, message)
	elif _connected: _server_message.rpc_id(1, message.merged({"type": "command"}))

func _receive_command(sender: int, message: Dictionary) -> void:
	if match_info.is_empty() or message.get("match_id") != match_info.match_id: return
	if not message.get("data", {}) is Dictionary or not str(message.get("action", "")) in ACTIONS: return
	var key := str(sender)
	var sequence := int(message.get("request_id", 0))
	if sequence <= int(_last_requests.get(key, 0)): return
	_last_requests[key] = sequence
	var role := str(match_info.role) if sender == 1 else ("defender" if match_info.role == "attacker" else "attacker")
	command_received.emit({"player_id": key, "role": role, "match_id": match_info.match_id, "request_id": sequence, "action": str(message.get("action", "")), "data": message.get("data", {})})

func snapshot(state: Dictionary) -> void:
	if not _hosting or _guest_peer == 0 or match_info.is_empty(): return
	sent_sequence += 1
	_client_message.rpc_id(_guest_peer, {"type": "state", "match_id": match_info.match_id, "seq": sent_sequence, "state": state})

func end_match(winner: String) -> void:
	if not _hosting or match_info.is_empty() or _ended or not winner in ["attacker", "defender"]: return
	_ended = true
	_client_message.rpc_id(_guest_peer, {"type": "end", "match_id": match_info.match_id, "winner": winner})
	match_ended.emit(winner)

func rematch() -> void:
	if match_info.is_empty() or not _ended: return
	if _hosting:
		_rematch["1"] = true
		_maybe_rematch()
	else:
		_server_message.rpc_id(1, {"type": "rematch", "match_id": match_info.match_id})

func _maybe_rematch() -> void:
	if _rematch.size() == 2:
		_start_match(true)
	else:
		_client_message.rpc_id(_guest_peer, {"type": "rematch_wait", "players": _rematch.size()})
		rematch_waiting.emit(_rematch.size())

func leave() -> void:
	stop_discovery()
	if _advertiser != null:
		_advertiser.close()
		_advertiser = null
	if multiplayer.multiplayer_peer != null:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	room = {}
	match_info = {}
	player_id = ""
	_hosting = false
	_connected = false
	_connecting = false
	_guest_peer = 0
	_loaded.clear()
	_rematch.clear()
	_last_requests.clear()
	_begun = false
	_ended = false

func host_address() -> String:
	var addresses := PackedStringArray()
	for address in IP.get_local_addresses():
		if not _valid_ipv4(address): continue
		var parts := address.split(".")
		var private_ip := address.begins_with("192.168.") or address.begins_with("10.") or (parts[0] == "172" and int(parts[1]) >= 16 and int(parts[1]) <= 31)
		if private_ip and not addresses.has(address): addresses.append(address)
	addresses.sort()
	return ", ".join(addresses) if not addresses.is_empty() else "No local Wi-Fi IP found"
