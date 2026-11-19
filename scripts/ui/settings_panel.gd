extends VBoxContainer
## Settings screen. Controls are authored in settings_panel.tscn; every change is
## stored and applied immediately by the GameSettings autoload.
const BUSES := ["Master", "Music", "SFX", "Voice"]
var _filling: bool = false

func _ready() -> void:
	for bus in BUSES:
		get_node("%" + bus + "Slider").value_changed.connect(_volume_changed.bind(bus))
	%MuteInBackground.toggled.connect(_store.bind("audio", "mute_in_background"))
	%WindowMode.item_selected.connect(_store.bind("display", "window_mode"))
	%Resolution.item_selected.connect(_store.bind("display", "resolution"))
	%MaxFps.item_selected.connect(func(index: int): _store(GameSettings.FPS_LIMITS[index], "display", "max_fps"))
	%VSync.toggled.connect(_store.bind("display", "vsync"))
	%ShowFps.toggled.connect(_store.bind("display", "show_fps"))
	%Subtitles.toggled.connect(_store.bind("display", "subtitles"))
	%ReducedEffects.toggled.connect(_store.bind("display", "reduced_effects"))
	%PlayerName.text_submitted.connect(func(_text: String): _save_name())
	%PlayerName.focus_exited.connect(_save_name)
	%SaveRelay.pressed.connect(_save_relay)
	%ResetRelay.pressed.connect(_reset_relay)
	%ResetAll.pressed.connect(func(): %ResetConfirm.popup_centered())
	%ResetConfirm.confirmed.connect(_reset_all)
	GameSettings.changed.connect(_settings_changed)
	visibility_changed.connect(func(): if is_visible_in_tree(): refresh())
	refresh()

## Copies the stored settings into the controls without triggering saves.
func refresh() -> void:
	_filling = true
	for bus in BUSES:
		get_node("%" + bus + "Slider").set_value_no_signal(GameSettings.volume(bus))
		get_node("%" + bus + "Value").text = "%d%%" % roundi(GameSettings.volume(bus))
	%MuteInBackground.set_pressed_no_signal(bool(GameSettings.get_setting("audio", "mute_in_background")))
	var mode: int = clampi(int(GameSettings.get_setting("display", "window_mode")), 0, %WindowMode.item_count - 1)
	%WindowMode.select(mode)
	%Resolution.select(clampi(int(GameSettings.get_setting("display", "resolution")), 0, %Resolution.item_count - 1))
	%Resolution.disabled = mode != GameSettings.WINDOWED
	%MaxFps.select(maxi(0, GameSettings.FPS_LIMITS.find(int(GameSettings.get_setting("display", "max_fps")))))
	%VSync.set_pressed_no_signal(bool(GameSettings.get_setting("display", "vsync")))
	%ShowFps.set_pressed_no_signal(bool(GameSettings.get_setting("display", "show_fps")))
	%Subtitles.set_pressed_no_signal(bool(GameSettings.get_setting("display", "subtitles")))
	%ReducedEffects.set_pressed_no_signal(bool(GameSettings.get_setting("display", "reduced_effects")))
	if not %PlayerName.has_focus(): %PlayerName.text = GameSettings.player_name()
	var online: Node = get_node_or_null("/root/OnlineSession")
	if online != null and not %RelayAddress.has_focus(): %RelayAddress.text = online.endpoint
	_filling = false

func _store(value: Variant, section: String, key: String) -> void:
	if _filling: return
	GameSettings.set_setting(section, key, value)
	%Status.text = "Saved."

func _volume_changed(value: float, bus: String) -> void:
	get_node("%" + bus + "Value").text = "%d%%" % roundi(value)
	if _filling: return
	GameSettings.set_volume(bus, value)

func _save_name() -> void:
	if _filling: return
	GameSettings.set_player_name(%PlayerName.text)
	%PlayerName.text = GameSettings.player_name()

func _save_relay() -> void:
	var online: Node = get_node_or_null("/root/OnlineSession")
	if online == null: return
	if not online.room.is_empty():
		%Status.text = "Leave your online room before changing the relay."
		return
	if online.configure(%RelayAddress.text):
		%RelayAddress.text = online.endpoint
		%Status.text = "Relay address saved."
	else:
		%Status.text = "Enter a wss:// address (or ws://localhost for testing)."

func _reset_relay() -> void:
	var online: Node = get_node_or_null("/root/OnlineSession")
	if online == null: return
	if not online.room.is_empty():
		%Status.text = "Leave your online room before changing the relay."
		return
	online.reset_endpoint()
	%RelayAddress.text = online.endpoint
	%Status.text = "Using the built-in relay address."

func _reset_all() -> void:
	GameSettings.reset_all()
	var online: Node = get_node_or_null("/root/OnlineSession")
	if online != null and online.room.is_empty(): online.reset_endpoint()
	refresh()
	%Status.text = "All settings restored to defaults."

func _settings_changed(_section: String, _key: String, _value: Variant) -> void:
	# Keep the screen in sync when settings change elsewhere (lobby, pause menu).
	if is_visible_in_tree(): refresh()
