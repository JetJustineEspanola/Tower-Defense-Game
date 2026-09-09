extends Node

signal changed
const PATH: String = "user://settings.cfg"
var save_path: String = PATH
var values: Dictionary = {"master": 0.8, "music": 0.65, "effects": 0.8, "brightness": 1.0, "fullscreen": false, "resolution": 0}

func _ready() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(save_path) == OK:
		for key: String in values:
			var value: Variant = config.get_value("settings", key, values[key])
			if typeof(value) == typeof(values[key]):
				values[key] = value
	for key: String in ["master", "music", "effects"]:
		values[key] = clampf(float(values[key]), 0.0, 1.0)
	values.brightness = clampf(float(values.brightness), 0.6, 1.4)
	values.resolution = clampi(int(values.resolution), 0, 1)
	apply()

func save_value(key: String, value: Variant) -> Error:
	values[key] = value
	var config: ConfigFile = ConfigFile.new()
	config.set_value("settings", "schema_version", 1)
	for field: String in values:
		config.set_value("settings", field, values[field])
	var error: Error = config.save(save_path)
	apply()
	changed.emit()
	return error

func apply() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, float(values.master))))
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
		if not values.fullscreen:
			DisplayServer.window_set_size(Vector2i(1366, 768) if int(values.resolution) == 0 else Vector2i(1920, 1080))
