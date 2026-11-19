extends Node
## Autoload "GameSettings": one persistent store for player options, applied at startup.
signal changed(section: String, key: String, value: Variant)
const PATH := "user://settings.cfg"
const LEGACY_PATH := "user://presentation.cfg"
const BUSES := ["Master", "Music", "SFX", "Voice"]
## Window mode indices used by the Settings screen.
const WINDOWED := 0
const FULLSCREEN := 1
const EXCLUSIVE_FULLSCREEN := 2
const RESOLUTIONS := [Vector2i(1280, 720), Vector2i(1366, 768), Vector2i(1600, 900), Vector2i(1920, 1080)]
const FPS_LIMITS := [0, 30, 60, 120, 144, 240]
const DEFAULTS := {
	"audio": {"Master": 100.0, "Music": 80.0, "SFX": 80.0, "Voice": 80.0, "mute_in_background": false},
	"display": {"reduced_effects": false, "subtitles": true, "window_mode": WINDOWED, "resolution": 1, "vsync": true, "max_fps": 0, "show_fps": false},
	"gameplay": {"player_name": ""},
}
var config := ConfigFile.new()
## Set false in tests so they never overwrite the player's real settings file.
var persist: bool = true
var _fps_layer: CanvasLayer
var _fps_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if config.load(PATH) != OK: _migrate_legacy()
	_build_fps_overlay()
	apply_all()

func get_setting(section: String, key: String) -> Variant:
	return config.get_value(section, key, DEFAULTS.get(section, {}).get(key))

func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	_save()
	_apply(section, key)
	changed.emit(section, key, value)

## Volume is stored as 0–100 to match the sliders.
func volume(bus: String) -> float:
	return clampf(float(get_setting("audio", bus)), 0.0, 100.0)

func set_volume(bus: String, value: float) -> void:
	set_setting("audio", bus, clampf(value, 0.0, 100.0))

func player_name() -> String:
	return str(get_setting("gameplay", "player_name")).strip_edges().left(20)

func set_player_name(value: String) -> void:
	value = value.strip_edges().left(20)
	if value != player_name(): set_setting("gameplay", "player_name", value)

func reset_all() -> void:
	config.clear()
	_save()
	apply_all()
	changed.emit("", "", null)

func apply_all() -> void:
	for bus in BUSES: _apply("audio", bus)
	_apply_display()
	_apply("display", "show_fps")

func _apply(section: String, key: String) -> void:
	if section == "audio" and key in BUSES:
		var index: int = AudioServer.get_bus_index(key)
		if index >= 0: AudioServer.set_bus_volume_linear(index, volume(key) / 100.0)
	elif section == "display" and key in ["window_mode", "resolution", "vsync", "max_fps"]:
		_apply_display()
	elif section == "display" and key == "show_fps":
		var shown: bool = bool(get_setting("display", "show_fps"))
		_fps_layer.visible = shown
		set_process(shown)

func _apply_display() -> void:
	Engine.max_fps = int(get_setting("display", "max_fps"))
	if DisplayServer.get_name() == "headless": return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if bool(get_setting("display", "vsync")) else DisplayServer.VSYNC_DISABLED)
	match int(get_setting("display", "window_mode")):
		FULLSCREEN: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		EXCLUSIVE_FULLSCREEN: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		_:
			if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			_apply_window_size()

## Resizes the window (never larger than the screen) and keeps it centred.
func _apply_window_size() -> void:
	var index: int = clampi(int(get_setting("display", "resolution")), 0, RESOLUTIONS.size() - 1)
	var screen: Rect2i = DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	var size: Vector2i = RESOLUTIONS[index].min(screen.size)
	if DisplayServer.window_get_size() == size: return
	DisplayServer.window_set_size(size)
	DisplayServer.window_set_position(screen.position + (screen.size - size) / 2)

func _notification(what: int) -> void:
	if not bool(get_setting("audio", "mute_in_background")): return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT: AudioServer.set_bus_mute(0, true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN: AudioServer.set_bus_mute(0, false)

func _build_fps_overlay() -> void:
	_fps_layer = CanvasLayer.new()
	_fps_layer.name = "FpsOverlay"
	_fps_layer.layer = 128
	_fps_label = Label.new()
	_fps_label.position = Vector2(10, 6)
	_fps_label.add_theme_font_size_override("font_size", 14)
	_fps_label.add_theme_color_override("font_color", Color(0.55, 1.0, 0.75))
	_fps_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_fps_label.add_theme_constant_override("outline_size", 4)
	_fps_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fps_layer.add_child(_fps_label)
	add_child(_fps_layer)

func _process(_delta: float) -> void:
	_fps_label.text = "%d FPS" % Engine.get_frames_per_second()

func _save() -> void:
	if persist: config.save(PATH)

## Earlier builds kept Music/SFX/Voice and display toggles in presentation.cfg.
func _migrate_legacy() -> void:
	var legacy := ConfigFile.new()
	if legacy.load(LEGACY_PATH) != OK: return
	for section in ["audio", "display"]:
		if not legacy.has_section(section): continue
		for key in legacy.get_section_keys(section): config.set_value(section, key, legacy.get_value(section, key))
	_save()
