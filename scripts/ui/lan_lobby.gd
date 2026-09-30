extends Control
## UI only: a future LAN service supplies rooms and guest state through these methods.
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

func _ready() -> void:
	$HostRoom/Questions.pressed.connect(func(): $DeckEditor.show())
	$DeckEditor.deck_applied.connect(_deck_applied)
	$Browser/Back.pressed.connect(_back)
	$Browser/Host.pressed.connect(_host)
	$Browser/Panel/Content/Heading/Refresh.pressed.connect(_refresh)
	$Browser/Panel/Content/Join.pressed.connect(_join)
	list.item_selected.connect(_room_selected)
	$HostRoom/Leave.pressed.connect(_leave)
	$HostRoom/Settings.pressed.connect(_settings)
	ready_button.toggled.connect(_ready_changed)
	start_button.pressed.connect(_start)
	$SettingsOverlay/Center/Panel/Content/Close.pressed.connect(func(): $SettingsOverlay.hide())
	$SettingsOverlay/Center/Panel/Content/Volume.value_changed.connect(_volume_changed)
	set_rooms([])

func _name() -> String:
	var value: String = player_name.text.strip_edges()
	return value if not value.is_empty() else "Player"

func _host() -> void:
	browser.hide()
	host_room.show()
	$Header/Title.text = "HOST LOBBY"
	$Header/Subtitle.text = "WAIT FOR PLAYERS AND START THE MATCH"
	$HostRoom/Panel/Content/Player1/Row/Text/Name.text = _name()
	ready_button.set_pressed_no_signal(true)
	_ready_changed(true)
	set_guest("", false)
	host_requested.emit(_name())

func _leave() -> void:
	leave_requested.emit()
	host_room.hide()
	browser.show()
	$Header/Title.text = "LAN LOBBY"
	$Header/Subtitle.text = "JOIN OR HOST A LOCAL NETWORK GAME"
	$Browser/Host.grab_focus()

func _back() -> void:
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
	$Browser/Panel/Content/Join.disabled = true

func _refresh() -> void:
	$Browser/Panel/Content/Status.text = "LAN discovery will be connected in the networking step."
	set_rooms(rooms)

func _room_selected(index: int) -> void:
	$Browser/Panel/Content/Join.disabled = index < 0 or index >= rooms.size() or int(rooms[index].get("players", 1)) >= 2

func _join() -> void:
	var selected := list.get_selected_items()
	if selected.is_empty(): return
	var room: Dictionary = rooms[selected[0]]
	if int(room.get("players", 1)) >= 2: return
	join_requested.emit(str(room.get("id", "")), _name())

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
	readiness_changed.emit(ready)
	_update_start()

func _update_start() -> void:
	start_button.disabled = not (guest_connected and guest_ready and ready_button.button_pressed)
	$HostRoom/Panel/Content/Status.text = "BOTH PLAYERS READY" if not start_button.disabled else ("WAITING FOR PLAYERS TO READY UP" if guest_connected else "WAITING FOR PLAYER 2\nBoth players must be ready before starting.")

func _start() -> void:
	if not start_button.disabled: start_requested.emit()

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
	guest_ready = false
	ready_button.set_pressed_no_signal(false)
	_ready_changed(false)
	$HostRoom/Panel/Content/Player2/Row/Text/Status.text = "NOT READY" if guest_connected else "NOT CONNECTED"
	var selected_deck: Dictionary = preload("res://scripts/questions/deck_store.gd").active()
	$HostRoom/Questions.text = "Astral deck: " + str(selected_deck.name)
