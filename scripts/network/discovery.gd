class_name LobbyDiscovery
extends Node

signal changed
const PORT: int = 24561
const MAGIC: String = "CODEBORN_DISCOVER_1"
var socket: PacketPeerUDP = PacketPeerUDP.new()
var hosting: bool = false
var browsing: bool = false
var sessions: Dictionary = {}
var elapsed: float = 0.0
var error_text: String = ""

func stop() -> void:
	socket.close()
	hosting = false
	browsing = false
	sessions.clear()
	error_text = ""

func host() -> void:
	stop()
	var error: Error = socket.bind(PORT)
	hosting = error == OK
	if error != OK:
		error_text = "Discovery port unavailable; use manual IP."

func browse() -> void:
	stop()
	var error: Error = socket.bind(0)
	browsing = error == OK
	if error != OK:
		error_text = "Cannot open discovery socket; use manual IP."
	socket.set_broadcast_enabled(true)
	elapsed = 1.0

func _process(delta: float) -> void:
	if not hosting and not browsing:
		return
	elapsed += delta
	if browsing and elapsed >= 1.0:
		elapsed = 0.0
		for address: String in ["255.255.255.255", "127.0.0.1"]:
			socket.set_dest_address(address, PORT)
			socket.put_packet(MAGIC.to_utf8_buffer())
	var budget: int = 32
	while socket.get_available_packet_count() > 0 and budget > 0:
		budget -= 1
		var packet: PackedByteArray = socket.get_packet()
		var address: String = socket.get_packet_ip()
		var port: int = socket.get_packet_port()
		if packet.size() > 1024:
			continue
		if hosting and packet.get_string_from_utf8() == MAGIC:
			var response: Dictionary = {"magic":MAGIC,"name":NetworkManager.lobby_name,"players":NetworkManager.roster.size(),"phase":NetworkManager.phase,"port":NetworkManager.game_port,"protocol":AppState.PROTOCOL,"hash":AppState.content_hash(),"duration":NetworkManager.duration}
			socket.set_dest_address(address, port)
			socket.put_packet(JSON.stringify(response).to_utf8_buffer())
		elif browsing:
			var data: Variant = JSON.parse_string(packet.get_string_from_utf8())
			if not data is Dictionary or data.get("magic") != MAGIC or not data.get("name") is String or data.name.length() > 40:
				continue
			if not data.get("port") is float or data.port < 1024 or data.port > 65535 or not data.get("players") is float or data.players < 1 or data.players > 2 or not data.get("duration") is float or data.duration < 600 or data.duration > 900:
				continue
			if data.get("phase") not in ["lobby","loading","reveal","game","results"] or not data.get("hash") is String:
				continue
			data.address = address
			data.seen = Time.get_ticks_msec()
			data.compatible = data.get("protocol") == AppState.PROTOCOL and data.hash == AppState.content_hash()
			if sessions.size() < 64 or sessions.has(address + ":" + str(int(data.port))):
				sessions[address + ":" + str(int(data.port))] = data
				changed.emit()
	for key: String in sessions.keys():
		if Time.get_ticks_msec() - int(sessions[key].seen) > 5000:
			sessions.erase(key)
			changed.emit()
