extends SceneTree

const MENU_SCENE: String = "res://scenes/codeborn_menu.tscn"
const LOBBY_SCENE: String = "res://scenes/UI/online_lobby.tscn"

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var viewport_sizes: Array[Vector2i] = [Vector2i(800, 600), Vector2i(1366, 768)]
	var test_viewport := SubViewport.new()
	root.add_child(test_viewport)
	test_viewport.size = viewport_sizes[0]

	var menu: Control = load(MENU_SCENE).instantiate()
	test_viewport.add_child(menu)
	await process_frame

	for viewport_size: Vector2i in viewport_sizes:
		test_viewport.size = viewport_size
		await process_frame
		menu.get_node("SettingsScreen").show()
		menu.get_node("DeveloperScreen").hide()
		await process_frame
		_check_panel(menu.get_node("SettingsScreen/CenterContainer/PanelContainer"), viewport_size, "Settings")

		menu.get_node("SettingsScreen").hide()
		menu.get_node("DeveloperScreen").show()
		await process_frame
		_check_panel(menu.get_node("DeveloperScreen/CenterContainer/PanelContainer"), viewport_size, "Developer")
		_check_full_rect(menu.get_node("MainMenu"), viewport_size, "MainMenu")
		_check_full_rect(menu.get_node("MainMenu/CenterContainer"), viewport_size, "MainMenu center")

	_check_anchor_mode(menu.get_node("MainMenu"), 1, "MainMenu")
	_check_anchor_mode(menu.get_node("MainMenu/CenterContainer"), 1, "MainMenu/CenterContainer")
	_check_anchor_mode(menu.get_node("SettingsScreen/CenterContainer"), 1, "Settings CenterContainer")
	_check_anchor_mode(menu.get_node("DeveloperScreen/CenterContainer"), 1, "Developer CenterContainer")

	var master_bus: int = AudioServer.get_bus_index("Master")
	_expect(master_bus >= 0, "Master audio bus exists")
	if master_bus >= 0:
		var original_volume: float = AudioServer.get_bus_volume_linear(master_bus)
		var slider: HSlider = menu.get_node("SettingsScreen/CenterContainer/PanelContainer/Content/VolumeSlider")
		slider.value = 35.0
		_expect(absf(AudioServer.get_bus_volume_linear(master_bus) - 0.35) < 0.01, "Settings slider sets Master volume to 35%")
		AudioServer.set_bus_volume_linear(master_bus, original_volume)

	menu.queue_free()
	await process_frame
	test_viewport.queue_free()
	await process_frame

	var play_menu: Control = load(MENU_SCENE).instantiate()
	root.add_child(play_menu)
	current_scene = play_menu
	await process_frame
	play_menu.get_node("MainMenu/CenterContainer/PanelContainer/Content/Buttons/PlayButton").emit_signal("pressed")
	await process_frame
	await process_frame
	_expect(current_scene != null and current_scene.scene_file_path == LOBBY_SCENE, "Play opens the online room lobby")
	if current_scene != null and current_scene.scene_file_path == LOBBY_SCENE:
		_check_full_rect(current_scene.get_node("Background"), Vector2i(1366, 768), "Play lobby background")
		_check_full_rect(current_scene.get_node("Browser"), Vector2i(1366, 768), "Play lobby Browser")

	for viewport_size: Vector2i in viewport_sizes:
		var lobby_viewport := SubViewport.new()
		root.add_child(lobby_viewport)
		lobby_viewport.size = viewport_size
		var lobby: Control = load(LOBBY_SCENE).instantiate()
		lobby_viewport.add_child(lobby)
		await process_frame
		_check_full_rect(lobby.get_node("Background"), viewport_size, "Lobby background")
		_check_full_rect(lobby.get_node("Browser"), viewport_size, "Lobby Browser")
		_check_anchor_mode(lobby.get_node("Background"), 1, "Lobby background")
		_check_anchor_mode(lobby.get_node("Browser"), 1, "Lobby Browser")
		_check_anchor_mode(lobby.get_node("HostRoom"), 1, "HostRoom")
		_check_anchor_mode(lobby.get_node("Header"), 1, "Lobby Header")
		_check_anchor_mode(lobby.get_node("Browser/Panel"), 1, "Browser panel")
		_check_anchor_mode(lobby.get_node("HostRoom/Panel"), 1, "HostRoom panel")
		_check_anchor_mode(lobby.get_node("Browser/Host"), 1, "Create Room button")
		_check_anchor_mode(lobby.get_node("ConnectionOverlay"), 1, "Connection overlay")
		_check_anchor_mode(lobby.get_node("ConnectionOverlay/Center"), 1, "Connection overlay center")
		_check_horizontal_margin(lobby.get_node("Browser/Back"), viewport_size, 38.0, "Back button")
		_check_horizontal_margin(lobby.get_node("Browser/Host"), viewport_size, 38.0, "Create Room button")
		lobby.queue_free()
		lobby_viewport.queue_free()
		await process_frame

	if failures == 0:
		print("PASS: menu panels, lobby anchors, and master volume")
		quit(0)
	else:
		push_error("%d menu/lobby regression check(s) failed" % failures)
		quit(1)

func _check_panel(panel: Control, viewport_size: Vector2i, label: String) -> void:
	var rect: Rect2 = panel.get_global_rect()
	_expect(absf(rect.get_center().x - viewport_size.x * 0.5) <= 2.0, "%s panel is horizontally centered at %s" % [label, viewport_size])
	_expect(absf(rect.get_center().y - viewport_size.y * 0.5) <= 2.0, "%s panel is vertically centered at %s" % [label, viewport_size])
	_expect(rect.position.x >= 0.0 and rect.end.x <= viewport_size.x, "%s panel fits viewport width at %s" % [label, viewport_size])
	_expect(rect.position.y >= 0.0 and rect.end.y <= viewport_size.y, "%s panel fits viewport height at %s" % [label, viewport_size])
	_expect(panel.get_theme_stylebox("panel") is StyleBoxTexture, "%s panel uses the lobby frame texture" % label)

func _check_full_rect(control: Control, viewport_size: Vector2i, label: String) -> void:
	var rect: Rect2 = control.get_global_rect()
	_expect(rect.position.distance_to(Vector2.ZERO) <= 1.0, "%s begins at viewport origin" % label)
	_expect(rect.size.distance_to(Vector2(viewport_size)) <= 1.0, "%s fills the viewport" % label)

func _check_anchor_mode(control: Control, expected_mode: int, label: String) -> void:
	_expect(int(control.get("layout_mode")) == expected_mode, "%s stores explicit anchor layout mode" % label)

func _check_horizontal_margin(control: Control, viewport_size: Vector2i, margin: float, label: String) -> void:
	var rect: Rect2 = control.get_global_rect()
	_expect(rect.position.x >= margin - 1.0, "%s keeps its left viewport margin" % label)
	_expect(rect.end.x <= viewport_size.x - margin + 1.0, "%s keeps its right viewport margin" % label)

func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error("FAIL: " + message)
