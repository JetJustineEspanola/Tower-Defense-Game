extends SceneTree
## Run: godot --headless --path . -s res://tests/ui/settings_panel_test.gd
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var settings: Node = root.get_node("GameSettings")
	settings.persist = false
	settings.config.clear()
	settings.apply_all()
	var panel: Control = load("res://scenes/UI/settings_panel.tscn").instantiate()
	root.add_child(panel)
	await process_frame

	for bus in ["Master", "Music", "SFX", "Voice"]:
		panel.get_node("%" + bus + "Slider").value = 40.0
		var index: int = AudioServer.get_bus_index(bus)
		_expect(absf(AudioServer.get_bus_volume_linear(index) - 0.4) < 0.01, "%s slider sets its bus to 40%%" % bus)
		_expect(panel.get_node("%" + bus + "Value").text == "40%", "%s shows its percentage" % bus)

	panel.get_node("%ShowFps").button_pressed = true
	_expect(settings.get_node("FpsOverlay").visible, "Show FPS turns on the counter")
	panel.get_node("%MaxFps").select(2)
	panel.get_node("%MaxFps").item_selected.emit(2)
	_expect(Engine.max_fps == 60, "Frame rate limit applies (60 FPS)")
	panel.get_node("%WindowMode").select(1)
	panel.get_node("%WindowMode").item_selected.emit(1)
	await process_frame
	_expect(int(settings.get_setting("display", "window_mode")) == 1, "Window mode is stored")
	_expect(panel.get_node("%Resolution").disabled, "Window size is disabled outside Windowed mode")

	panel.get_node("%PlayerName").text = "  Jet  "
	panel.get_node("%PlayerName").text_submitted.emit("")
	_expect(settings.player_name() == "Jet", "Player name is saved without extra spaces")
	settings.set_player_name("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	_expect(settings.player_name() == "ABCDEFGHIJKLMNOPQRST", "Player name is limited to 20 characters")

	var online: Node = root.get_node("OnlineSession")
	var built_in: String = online.default_endpoint()
	panel.get_node("%RelayAddress").text = "http://not-secure.example"
	panel.get_node("%SaveRelay").pressed.emit()
	_expect(online.endpoint == built_in, "Insecure relay address is rejected")

	settings.reset_all()
	panel.refresh()
	_expect(is_equal_approx(settings.volume("Music"), 80.0) and absf(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Music")) - 0.8) < 0.01, "Reset restores and applies default volume")
	_expect(not settings.get_node("FpsOverlay").visible and Engine.max_fps == 0, "Reset hides FPS and removes the frame cap")
	_expect(panel.get_node("%PlayerName").text.is_empty(), "Reset clears the player name")

	panel.queue_free()
	await process_frame
	print("FAIL: %d settings check(s)" % failures if failures else "PASS: settings panel and GameSettings")
	quit(1 if failures else 0)

func _expect(condition: bool, label: String) -> void:
	if condition: return
	failures += 1
	push_error(label)
	print("  x ", label)
