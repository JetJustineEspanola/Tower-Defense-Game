extends Node
## Autoload "GameSettings": one persistent store for player options, applied at startup.
signal changed(section: String, key: String, value: Variant)
const PATH := "user://settings.cfg"
const LEGACY_PATH := "user://presentation.cfg"
const BUSES := ["Master", "Music", "SFX", "Voice"]
const DEFAULTS := {
	"audio": {"Master": 100.0, "Music": 80.0, "SFX": 80.0, "Voice": 80.0},
	"display": {"reduced_effects": false, "subtitles": true},
}
var config := ConfigFile.new()
## Set false in tests so they never overwrite the player's real settings file.
var persist: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if config.load(PATH) != OK: _migrate_legacy()
	for bus in BUSES: _apply_volume(bus, volume(bus))

func get_setting(section: String, key: String) -> Variant:
	return config.get_value(section, key, DEFAULTS.get(section, {}).get(key))

func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	if persist: config.save(PATH)
	changed.emit(section, key, value)

## Volume is stored as 0–100 to match the sliders.
func volume(bus: String) -> float:
	return clampf(float(get_setting("audio", bus)), 0.0, 100.0)

func set_volume(bus: String, value: float) -> void:
	value = clampf(value, 0.0, 100.0)
	_apply_volume(bus, value)
	set_setting("audio", bus, value)

func _apply_volume(bus: String, value: float) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index >= 0: AudioServer.set_bus_volume_linear(index, value / 100.0)

## Earlier builds kept Music/SFX/Voice and display toggles in presentation.cfg.
func _migrate_legacy() -> void:
	var legacy := ConfigFile.new()
	if legacy.load(LEGACY_PATH) != OK: return
	for section in ["audio", "display"]:
		if not legacy.has_section(section): continue
		for key in legacy.get_section_keys(section): config.set_value(section, key, legacy.get_value(section, key))
	if persist: config.save(PATH)
