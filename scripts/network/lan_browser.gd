extends CodeBornScreen

var sessions: ItemList
var endpoints: Array[Dictionary] = []
var ip: LineEdit
var player: LineEdit
var port: SpinBox
var message: Label

func _ready() -> void:
	super._ready()
	var col: VBoxContainer = page("LOCAL NETWORK", "Find a rival on the same Wi-Fi or hotspot.")
	var details: HBoxContainer = UI.row(col)
	UI.label(details,"Your name")
	player = UI.input(details,"Display name","Player")
	UI.label(details,"Game port")
	port = SpinBox.new()
	port.min_value = 1024
	port.max_value = 65535
	port.value = NetworkManager.DEFAULT_PORT
	details.add_child(port)
	sessions = ItemList.new()
	sessions.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sessions.add_theme_constant_override("v_separation",18)
	col.add_child(sessions)
	var controls: HBoxContainer = UI.row(col)
	UI.button(controls,"Join selected",_join_selected)
	UI.button(controls,"Refresh",func() -> void: NetworkManager.discovery.browse(); _refresh())
	UI.button(controls,"Host Game",func() -> void: NetworkManager.host(player.text + "'s lobby",player.text,int(port.value)))
	var direct: HBoxContainer = UI.row(col)
	ip = UI.input(direct,"Host IPv4 address","127.0.0.1")
	UI.button(direct,"Join by IP",func() -> void: NetworkManager.join(ip.text.strip_edges(),player.text,int(port.value)))
	message = UI.paragraph(col,AppState.notice if not AppState.notice.is_empty() else "Searching for lobbies...",18,UI.CYAN)
	AppState.notice = ""
	UI.paragraph(col,"No sessions? Check that both PCs use the same build and question pack. Allow the game on your private network in Windows Firewall. Guest-network isolation can block LAN connections.",16)
	UI.button(col,"Back",SceneRouter.menu)
	NetworkManager.status_changed.connect(func(text: String) -> void: message.text = text)
	NetworkManager.discovery.changed.connect(_refresh)
	NetworkManager.discovery.browse()
	_refresh()

func _refresh() -> void:
	sessions.clear()
	endpoints.clear()
	for data: Dictionary in NetworkManager.discovery.sessions.values():
		endpoints.append(data)
		var suffix: String = "" if data.compatible else " / INCOMPATIBLE"
		sessions.add_item("%s    %s/2 players    %s min    %s    %s%s" % [data.name,int(data.players),int(data.duration)/60,data.phase,data.address,suffix])
		sessions.set_item_disabled(sessions.item_count-1,not data.compatible or int(data.players)>=2 or data.phase != "lobby")
	if endpoints.is_empty():
		sessions.add_item("No hosted games found yet. Host a game or use the IP fallback below.")
		sessions.set_item_disabled(0,true)

func _join_selected() -> void:
	if sessions.get_selected_items().is_empty():
		message.text = "Select an available lobby first."
		return
	var index: int = sessions.get_selected_items()[0]
	if index >= endpoints.size():
		return
	var data: Dictionary = endpoints[index]
	NetworkManager.join(data.address,player.text,int(data.port))

func _exit_tree() -> void:
	if not NetworkManager.discovery.hosting:
		NetworkManager.discovery.stop()
