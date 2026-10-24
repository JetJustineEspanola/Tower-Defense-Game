extends SceneTree

class FakeClock extends Node:
	var running := true

class FakeActor extends Node:
	var resources: Node
	var clock: Node

class FakeOnlineGame extends Node:
	var authority := true
	var local_role := "attacker"
	var relayed: Array[Dictionary] = []
	func record_visual(actor: Node, event: String, data: Dictionary) -> void:
		relayed.append({"actor": actor, "event": event, "data": data})

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/combat/jet_voice.tscn")
	_expect(scene != null, "shared voice scene loads")
	if scene != null:
		var voice: Node = scene.instantiate()
		var banks: Dictionary = voice.get("character_banks")
		_expect(banks.has("Arjie"), "Arjie uses the shared voice player")
		if banks.has("Arjie"):
			var bank: Resource = banks["Arjie"]
			var expected := {
				"placed": ["Placed.mp3"],
				"selected": ["Selected.mp3"],
				"upgraded": ["Upgraded.mp3"],
				"summons": ["Summons.mp3"],
				"guard_reposition": ["Guard-Reposition.mp3"],
				"low_health": ["Low-health.mp3"],
				"defeated": ["Defeated.mp3"],
				"guard_attack": ["Extrasound_Attack-01.mp3", "Extrasound_Attack-02.mp3"],
				"guard_hurt": ["Extrasound_hurt-01.mp3", "Extrasound_hurt-02.mp3"],
				"guard_defeated": ["Extrasound_Defeat.mp3"],
			}
			for event in expected:
				var clips: Array = bank.get(event) if _has_property(bank, event) else []
				_expect(clips.size() == expected[event].size(), "%s has expected clips" % event)
				for i in mini(clips.size(), expected[event].size()):
					_expect(clips[i] is AudioStream, "%s clip %d is playable" % [event, i])
					_expect(String(clips[i].resource_path).ends_with(expected[event][i]), "%s clip %d maps correctly" % [event, i])
			var game := FakeOnlineGame.new()
			game.name = "Game"
			root.add_child(game)
			current_scene = game
			var experience := Node.new()
			experience.name = "Experience"
			game.add_child(experience)
			var speaking := AudioStreamPlayer.new()
			speaking.name = "Voice"
			experience.add_child(speaking)
			var gameplay := Node.new()
			gameplay.name = "Gameplay"
			game.add_child(gameplay)
			var hud := Node.new()
			hud.name = "ResourceHUD"
			gameplay.add_child(hud)
			var question := Node.new()
			question.name = "ArcaneQuestionTest"
			hud.add_child(question)
			var clock := FakeClock.new()
			clock.name = "MatchClock"
			question.add_child(clock)
			game.add_child(voice)
			var actor := FakeActor.new()
			actor.resources = Node.new()
			actor.clock = clock
			game.add_child(actor)
			actor.add_child(actor.resources)
			_expect(voice.request_for("Arjie", "guard_reposition", actor), "Arjie event plays through shared player")
			_expect(voice.get_node("Player").stream == bank.guard_reposition[0], "shared player receives Arjie's clip")
			voice.get_node("Player").stop()
			voice.get_node("Player").stream = null
			_expect(not voice.request_arjie("summons", actor), "attacker host does not hear Arjie")
			_expect(game.relayed.size() == 1 and game.relayed[0].event == "arjie_voice", "host relays Arjie event")
			game.authority = false
			game.local_role = "defender"
			_expect(not voice.request_arjie("summons", actor), "guest replica does not play Arjie twice")
			game.free()
			current_scene = null
			voice = null
		if voice != null: voice.free()
	await create_timer(0.5).timeout
	print("Arjie voice: %d failure(s)" % failures)
	quit(1 if failures else 0)

func _has_property(object: Object, name: String) -> bool:
	for property in object.get_property_list():
		if String(property.name) == name:
			return true
	return false

func _expect(condition: bool, description: String) -> void:
	if not condition:
		failures += 1
		push_error(description)
