extends Node
signal room_changed(room: Dictionary)
signal status_changed(message: String)
signal room_closed(message: String)
signal match_started
signal match_begin
signal command_received(message: Dictionary)
signal state_received(state: Dictionary)
signal match_ended(winner: String)
signal rematch_waiting(players: int)
var match_info: Dictionary = {}
var request_counter: int = 0
var received_sequence: int = -1
var sent_sequence: int = 0
const CONFIG = preload("res://resources/network/room_connection.tres")
const BUILD = "codeborn-match-1"
const STORE = preload("res://scripts/questions/deck_store.gd")
var socket: WebSocketPeer
var player_id: String = ""
var room: Dictionary = {}
var pending: Dictionary = {}
var started: int = 0
var greeted: bool = false
var endpoint: String = ""
var last_error: String = ""
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 endpoint = CONFIG.relay_url
 var settings := ConfigFile.new()
 if settings.load("user://online.cfg") == OK: endpoint = str(settings.get_value("relay", "url", ""))
func configure(url: String) -> bool:
 url = url.strip_edges().trim_suffix("/")
 if not (url.begins_with("wss://") or url.begins_with("ws://127.0.0.1:") or url.begins_with("ws://localhost:")):
  status_changed.emit("Enter a wss:// relay address, or localhost for development.")
  return false
 endpoint = url
 var settings := ConfigFile.new()
 settings.set_value("relay", "url", endpoint)
 settings.save("user://online.cfg")
 return true
func create_room(player_name: String, deck: Dictionary) -> void:
 _connect_request({"type": "create", "name": player_name, "deck": _network_deck(deck)})
func join_room(player_name: String, code: String) -> void:
 _connect_request({"type": "join", "name": player_name, "code": code.strip_edges().to_upper()})
func _connect_request(request: Dictionary) -> void:
 if endpoint.is_empty(): status_changed.emit("Set the relay address in Connection settings first."); return
 if not room.is_empty(): return
 pending = request
 last_error = ""
 if socket != null and socket.get_ready_state() == WebSocketPeer.STATE_OPEN and greeted:
  send(pending); pending = {}; return
 if socket != null: socket.close()
 socket = WebSocketPeer.new()
 socket.inbound_buffer_size = 1048576
 socket.outbound_buffer_size = 1048576
 socket.max_queued_packets = 128
 greeted = false
 player_id = ""
 started = Time.get_ticks_msec()
 var error: int = socket.connect_to_url(endpoint)
 if error != OK: socket = null; pending = {}; status_changed.emit("Could not connect to relay."); return
 status_changed.emit("Connecting to room service...")
func send(message: Dictionary) -> void:
 if socket == null or socket.get_ready_state() != WebSocketPeer.STATE_OPEN: return
 var serialized: String = JSON.stringify(message)
 var limit: int = 480000 if message.get("type") == "state" else 250000
 if serialized.to_utf8_buffer().size() > limit: status_changed.emit("Online data is too large. Use a smaller question deck."); return
 if socket.send_text(serialized) != OK: status_changed.emit("Request could not be sent. Please reconnect.")
func set_ready(value: bool) -> void:
 send({"type": "ready", "ready": value, "revision": room.get("deck_revision", 0)})
func update_deck(deck: Dictionary) -> void:
 send({"type": "deck", "deck": _network_deck(deck)})
func _network_deck(deck: Dictionary) -> Dictionary:
 var copy: Dictionary = deck.duplicate(true)
 copy.notes = []
 return copy
func leave() -> void:
 send({"type": "leave"})
 if socket != null: socket.close()
 socket = null
 pending = {}; room = {}; match_info = {}; player_id = ""; greeted = false
func _process(_delta: float) -> void:
 if socket == null: return
 socket.poll()
 var state: int = socket.get_ready_state()
 if not greeted and Time.get_ticks_msec() - started > CONFIG.connection_timeout_seconds * 1000:
  leave(); room_closed.emit("Connection timed out. Check the relay address and try again."); return
 if state == WebSocketPeer.STATE_OPEN:
  if not greeted and player_id.is_empty():
   send({"type": "hello", "build": BUILD})
   player_id = "waiting"
  while socket != null and socket.get_available_packet_count() > 0:
   var message = JSON.parse_string(socket.get_packet().get_string_from_utf8())
   if message is Dictionary: _receive(message)
 elif state == WebSocketPeer.STATE_CLOSED:
  var reason: String = last_error if not last_error.is_empty() else "Connection closed. Rejoin with your friend's code."
  leave(); room_closed.emit(reason)
func _receive(message: Dictionary) -> void:
 match str(message.get("type", "")):
  "match_start":
   if not STORE.valid(message.get("deck", {})).is_empty(): room_closed.emit("Invalid match deck."); leave(); return
   match_info = message
   received_sequence = -1; sent_sequence = 0; request_counter = 0
   match_started.emit()
  "begin":
   if message.get("match_id") == match_info.get("match_id"): match_begin.emit()
  "command":
   if message.get("match_id") == match_info.get("match_id"): command_received.emit(message)
  "state":
   if message.get("match_id") == match_info.get("match_id") and int(message.get("seq", -1)) > received_sequence:
    received_sequence = int(message.seq)
    state_received.emit(message.state)
  "end":
   if message.get("match_id") == match_info.get("match_id"): match_ended.emit(str(message.winner))
  "rematch_wait": rematch_waiting.emit(int(message.get("players", 0)))
  "hello":
   greeted = true; player_id = str(message.player_id)
   if not pending.is_empty(): send(pending); pending = {}
  "error":
   last_error = str(message.get("message", "Request rejected."))
   status_changed.emit(last_error)
  "room_closed":
   leave(); room_closed.emit(str(message.get("message", "Room closed.")))
  "room":
   var deck = message.get("deck", {})
   if not deck is Dictionary or not STORE.valid(deck).is_empty():
    leave(); room_closed.emit("The room's question deck is invalid."); return
   room = message
   send({"type": "deck_ack", "revision": room.deck_revision})
   room_changed.emit(room)
func _exit_tree() -> void: leave()

func is_host() -> bool: return player_id == str(room.get("host_id", ""))
func start_match() -> void: send({"type": "start"})
func loaded() -> void: send({"type": "loaded", "match_id": match_info.get("match_id", "")})
func command(action: String, data: Dictionary) -> void:
 request_counter += 1
 send({"type": "command", "match_id": match_info.get("match_id", ""), "request_id": request_counter, "action": action, "data": data})
func snapshot(state: Dictionary) -> void:
 sent_sequence += 1
 send({"type": "state", "match_id": match_info.get("match_id", ""), "seq": sent_sequence, "state": state})
func end_match(winner: String) -> void: send({"type": "end", "match_id": match_info.get("match_id", ""), "winner": winner})
func rematch() -> void: send({"type": "rematch"})
