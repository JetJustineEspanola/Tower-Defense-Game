extends CodeBornScreen

var roster_text: Label
var ready_button: Button
var start_button: Button
var message: Label
var timer_select: OptionButton

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = centered(720)
	UI.label(col,"CODE BORN  /  WAITING ROOM",32,UI.CYAN)
	UI.label(col,NetworkManager.lobby_name,24)
	var pane: VBoxContainer = UI.panel(col)
	roster_text = UI.label(pane,"",24)
	UI.label(pane,"Arcane Crossing  •  Beginner GDScript 4.6",16,UI.MUTED)
	var addresses: PackedStringArray = []
	for address: String in IP.get_local_addresses():
		if not address.contains(":") and not address.begins_with("127.") and not address.begins_with("169.254."):
			addresses.append(address)
	if not NetworkManager.is_host():
		addresses = PackedStringArray([NetworkManager.host_address])
	UI.paragraph(pane,"Host addresses: " + ", ".join(addresses) + "  |  UDP " + str(NetworkManager.game_port),16)
	UI.button(pane,"Copy host addresses",func() -> void: DisplayServer.clipboard_set(", ".join(addresses)))
	timer_select = OptionButton.new()
	for minutes: int in range(10,16):
		timer_select.add_item("%s minute match" % minutes,minutes*60)
	timer_select.selected = NetworkManager.duration/60-10
	timer_select.disabled = not NetworkManager.is_host()
	timer_select.item_selected.connect(func(index: int) -> void: NetworkManager.set_duration(timer_select.get_item_id(index)))
	pane.add_child(timer_select)
	ready_button = UI.button(col,"Ready",func() -> void: NetworkManager.set_ready(not NetworkManager.roster[NetworkManager.local_id()].ready))
	start_button = UI.button(col,"Start Game",func() -> void: NetworkManager.start_game())
	start_button.visible = NetworkManager.is_host()
	message = UI.paragraph(col,NetworkManager.status,18,UI.CYAN)
	UI.button(col,"Disconnect / Back",func() -> void: NetworkManager.leave(); SceneRouter.go("browser"))
	NetworkManager.lobby_changed.connect(_refresh)
	NetworkManager.status_changed.connect(func(text: String) -> void: message.text = text)
	_refresh()

func _refresh() -> void:
	var lines: PackedStringArray = []
	for peer: int in NetworkManager.roster:
		var player: Dictionary = NetworkManager.roster[peer]
		lines.append("%s%s   /   %s" % [player.name," (Host)" if peer == 1 else "", "READY" if player.ready else "Not ready"])
	if lines.size() < 2:
		lines.append("Waiting for a second player...")
	roster_text.text = "\n\n".join(lines)
	start_button.disabled = not NetworkManager.can_start()
	if NetworkManager.roster.has(NetworkManager.local_id()):
		ready_button.text = "Cancel Ready" if NetworkManager.roster[NetworkManager.local_id()].ready else "Ready"
	timer_select.selected = NetworkManager.duration/60-10
