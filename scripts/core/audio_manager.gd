extends Node

# Art/audio contributors can attach licensed streams without touching gameplay.
var music: AudioStreamPlayer
var effects: AudioStreamPlayer

func _ready() -> void:
	for bus_name: String in ["Music", "Effects"]:
		if AudioServer.get_bus_index(bus_name) < 0:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	effects = AudioStreamPlayer.new()
	effects.bus = "Effects"
	add_child(effects)
	SettingsManager.changed.connect(apply)
	apply()

func apply() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(maxf(0.0001, SettingsManager.values.music)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Effects"), linear_to_db(maxf(0.0001, SettingsManager.values.effects)))
