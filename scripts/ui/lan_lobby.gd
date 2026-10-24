extends Control
## The online lobby inherits this layout and overrides its transport actions.
signal host_requested(player_name: String)
signal join_requested(room_id: String, player_name: String)
signal leave_requested
signal start_requested
signal readiness_changed(ready: bool)
var rooms: Array[Dictionary] = []
var guest_connected: bool = false
var guest_ready: bool = false
@onready var browser: Control = $Browser
@onready var host_room: Control = $HostRoom
@onready var list: ItemList = $Browser/Panel/Content/ListArea/Rooms
@onready var player_name: LineEdit = $Browser/Panel/Content/Identity/PlayerName
@onready var ready_button: Button = $HostRoom/Panel/Content/Actions/Ready
@onready var start_button: Button = $HostRoom/Panel/Content/Actions/Start
@onready var lan_service: Node = get_node_or_null("/root/LanSession")

func _lan_mode() -> bool:
	return get_script().resource_path == "res://scripts/ui/lan_lobby.gd"

func _ready() -> void:
	$HostRoom/Questions.pressed.connect(func(): $DeckEditor.show())
	$DeckEditor.deck_applied.connect(_deck_applied)
	$Browser/Back.pressed.connect(_back)
	$Browser/Host.pressed.connect(_host)
	$Browser/Panel/Content/Heading/Refresh.pressed.connect(_refresh)
	$Browser/Panel/Content/Join.pressed.connect(_join)
	$Browser/Panel/Content/ListArea/DirectIP.text_submitted.connect(func(_value: String): _join())
	$Browser/Panel/Content/ListArea/DirectIP.text_changed.connect(func(_value: String): _update_join_button())
	list.item_selected.connect(_room_selected)
	$HostRoom/Leave.pressed.connect(_leave)
	$HostRoom/Settings.pressed.connect(_settings)
	ready_button.toggled.connect(_ready_changed)
	start_button.pressed.connect(_start)
	$SettingsOverlay/Center/Panel/Content/Close.pressed.connect(func(): $SettingsOverlay.hide())
	$SettingsOverlay/Center/Panel/Content/Volume.value_changed.connect(_volume_changed)
	set_rooms([])
	if _lan_mode() and lan_service != null:
		lan_service.rooms_found.connect(set_rooms)
		lan_service.room_changed.connect(_room_update)
		lan_service.status_changed.connect(_status)
		lan_service.room_closed.connect(_disconnected)
		lan_service.match_started.connect(_enter_match)
		lan_service.discover()

func _name() -> String:
	var value: String = player_name.text.strip_edges()
	return value if not value.is_empty() else "Player"

func _host() -> void:
	if lan_service != null:
		lan_service.create_room(_name(), preload("res://scripts/questions/deck_store.gd").active())

func _leave() -> void:
	if _lan_mode() and lan_service != null:
		lan_service.leave()
		lan_service.discover()
	leave_requested.emit()
	host_room.hide()
	browser.show()
	$Header/Title.text = "LAN LOBBY"
	$Header/Subtitle.text = "JOIN OR HOST A LOCAL NETWORK GAME"
	$Browser/Host.grab_focus()

func _back() -> void:
	if _lan_mode() and lan_service != null: lan_service.leave()
	get_tree().change_scene_to_file("res://scenes/codeborn_menu.tscn")

func set_rooms(available: Array[Dictionary]) -> void:
	rooms = available.duplicate(true)
	list.clear()
	for room in rooms:
		list.add_item("%s    •    %d / 2 players" % [str(room.get("name", "LAN Room")), int(room.get("players", 1))])
		list.set_item_disabled(list.item_count - 1, int(room.get("players", 1)) >= 2)
	list.visible = not rooms.is_empty()
	$Browser/Panel/Content/ListArea/Empty.visible = rooms.is_empty()
	$Browser/Panel/Content/Count.text = "FOUND %d GAMES" % rooms.size()
	_update_join_button()

func _refresh() -> void:
	set_rooms([])
	if lan_service != null: lan_service.discover()
	_status("Searching for LAN rooms. You can also enter the host IP.")

func _room_selected(index: int) -> void:
	_update_join_button()

func _update_join_button() -> void:
	var direct_ip: String = $Browser/Panel/Content/ListArea/DirectIP.text.strip_edges()
	var selected := list.get_selected_items()
	var selected_open: bool = not selected.is_empty() and selected[0] < rooms.size() and int(rooms[selected[0]].get("players", 1)) < 2
	$Browser/Panel/Content/Join.disabled = direct_ip.is_empty() and not selected_open

func _join() -> void:
	var address: String = $Browser/Panel/Content/ListArea/DirectIP.text.strip_edges()
	if not address.is_empty():
		lan_service.join_room(address, _name())
		return
	var selected := list.get_selected_items()
	if selected.is_empty():
		_status("Select a nearby room or enter the host IP address.")
		return
	var room: Dictionary = rooms[selected[0]]
	if int(room.get("players", 1)) >= 2: return
	lan_service.join_room(str(room.get("id", "")), _name())

func set_guest(guest_name: String, ready: bool) -> void:
	guest_connected = not guest_name.is_empty()
	guest_ready = guest_connected and ready
	$HostRoom/Panel/Content/Player2/Row/Text/Name.text = guest_name if guest_connected else "WAITING FOR PLAYER 2"
	$HostRoom/Panel/Content/Player2/Row/Text/Status.text = ("READY" if guest_ready else "NOT READY") if guest_connected else "NOT CONNECTED"
	$HostRoom/Panel/Content/Heading/Count.text = "2 / 2 PLAYERS" if guest_connected else "1 / 2 PLAYERS"
	_update_start()

func _ready_changed(ready: bool) -> void:
	ready_button.text = "✓ READY" if ready else "READY UP"
	$HostRoom/Panel/Content/Player1/Row/Text/Status.text = "HOST  •  READY" if ready else "HOST  •  NOT READY"
	if _lan_mode() and lan_service != null: lan_service.set_ready(ready)
	readiness_changed.emit(ready)
	_update_start()

func _update_start() -> void:
	var members: Array = lan_service.room.get("players", []) if _lan_mode() and lan_service != null else []
	var both_ready: bool = members.size() == 2
	for member in members: both_ready = both_ready and bool(member.get("ready", false))
	start_button.disabled = not (both_ready and lan_service.is_host()) if _lan_mode() and lan_service != null else not (guest_connected and guest_ready and ready_button.button_pressed)
	start_button.text = "START MATCH" if lan_service == null or lan_service.is_host() else "HOST STARTS MATCH"
	if _lan_mode() and lan_service != null and both_ready and not lan_service.is_host():
		$HostRoom/Panel/Content/Status.text = "Both players ready. Waiting for host to start."
	else:
		$HostRoom/Panel/Content/Status.text = "BOTH PLAYERS READY" if not start_button.disabled else ("WAITING FOR PLAYERS TO READY UP" if guest_connected else "WAITING FOR PLAYER 2\nBoth players must be ready before starting.")

func _start() -> void:
	if not start_button.disabled:
		if _lan_mode() and lan_service != null: lan_service.start_match()
		start_requested.emit()

func _settings() -> void:
	var volume: float = AudioServer.get_bus_volume_linear(0) * 100.0
	$SettingsOverlay/Center/Panel/Content/Volume.set_value_no_signal(volume)
	$SettingsOverlay/Center/Panel/Content/VolumeLabel.text = "Master volume • %d%%" % roundi(volume)
	$SettingsOverlay.show()

func _volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value / 100.0)
	$SettingsOverlay/Center/Panel/Content/VolumeLabel.text = "Master volume • %d%%" % roundi(value)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if $DeckEditor.visible:
			$DeckEditor.hide()
			get_viewport().set_input_as_handled()
			return
		if $SettingsOverlay.visible: $SettingsOverlay.hide()
		elif host_room.visible: _leave()
		else: _back()
		get_viewport().set_input_as_handled()

func _deck_applied() -> void:
	if _lan_mode() and lan_service != null:
		lan_service.update_deck(preload("res://scripts/questions/deck_store.gd").active())
		return
	guest_ready = false
	ready_button.set_pressed_no_signal(false)
	_ready_changed(false)
	$HostRoom/Panel/Content/Player2/Row/Text/Status.text = "NOT READY" if guest_connected else "NOT CONNECTED"
	var selected_deck: Dictionary = preload("res://scripts/questions/deck_store.gd").active()
	$HostRoom/Questions.text = "Astral deck: " + str(selected_deck.name)

func _status(message: String) -> void:
	$Browser/Panel/Content/Status.text = message
	if host_room.visible: $HostRoom/Panel/Content/Status.text = message

func _disconnected(message: String) -> void:
	host_room.hide()
	browser.show()
	_status(message)
	if lan_service != null: lan_service.discover()

func _room_update(state: Dictionary) -> void:
	browser.hide()
	host_room.show()
	var is_host: bool = lan_service.is_host()
	$Header/Title.text = "HOST LOBBY" if is_host else "GAME LOBBY"
	$Header/Subtitle.text = "WAIT FOR YOUR FRIEND TO JOIN" if is_host else "CONNECTED TO THE HOST"
	$HostRoom/Panel/Content/Connection.text = "LAN • Host IPs (use Wi-Fi): " + lan_service.host_address() if is_host else "LAN • Connected to host"
	$HostRoom/Questions.disabled = not is_host
	$HostRoom/Questions.text = "Astral deck: " + str(state.deck.get("name", "Default"))
	var members: Array = state.get("players", [])
	guest_connected = members.size() == 2
	$HostRoom/Panel/Content/Heading/Count.text = "%d / 2 PLAYERS" % members.size()
	for index in 2:
		var base := "HostRoom/Panel/Content/Player%d/Row/Text/" % (index + 1)
		if index < members.size():
			var member: Dictionary = members[index]
			get_node(base + "Name").text = str(member.name) + (" (YOU)" if str(member.id) == lan_service.player_id else "")
			get_node(base + "Status").text = ("HOST • " if member.host else "GUEST • ") + ("READY" if member.ready else "NOT READY")
			if str(member.id) == lan_service.player_id:
				ready_button.set_pressed_no_signal(bool(member.ready))
				ready_button.text = "✓ READY" if member.ready else "READY UP"
		else:
			get_node(base + "Name").text = "WAITING FOR PLAYER 2"
			get_node(base + "Status").text = "NOT CONNECTED"
	_update_start()

func _enter_match() -> void:
	get_tree().change_scene_to_file("res://scenes/network/lan_match.tscn")

func _exit_tree() -> void:
	if not _lan_mode() or lan_service == null: return
	for pair in [[lan_service.rooms_found, set_rooms], [lan_service.room_changed, _room_update], [lan_service.status_changed, _status], [lan_service.room_closed, _disconnected], [lan_service.match_started, _enter_match]]:
		if pair[0].is_connected(pair[1]): pair[0].disconnect(pair[1])
