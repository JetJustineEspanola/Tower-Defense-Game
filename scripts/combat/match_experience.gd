extends CanvasLayer
## Shared local presentation and active abilities. Controls are scene-authored.
@export_range(1, 120) var ability_cooldown: float = 40.0
@export_range(1, 20) var ability_duration: float = 6.0
@export_range(1.1, 3.0) var ability_multiplier: float = 1.5
var role: String = "defender"
var cooldown: float = 0.0
var active_remaining: float = 0.0
var finished: bool = false
var critical_announced: bool = false
var minute_announced: bool = false
var previous_health: int = 100
var base_damage: int = 0
var question_gold: int = 0
var questions_correct: int = 0
var bugs_defeated: int = 0
var towers_destroyed: int = 0
var tower_damage: Dictionary = {}
var reduced_effects: bool = false
var subtitles: bool = true
var voice_priority: int = -1
var notice_time: float = 0.0
var reward_tween: Tween
var config := ConfigFile.new()
@onready var hud = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest")
@onready var clock: MatchClock = hud.get_node("MatchClock")
@onready var base: Node3D = get_parent().get_node("Gameplay/AlliedBase")

func _ready() -> void:
	role = "attacker" if get_parent().has_node("Roster") else "defender"
	$Ability.pressed.connect(_ability)
	$Voice.finished.connect(func(): voice_priority = -1; $Subtitle.hide())
	hud.question_rewarded.connect(_question_reward)
	config.load("user://presentation.cfg")
	var settings = hud.get_node("PauseOverlay/Center/Panel/Content/AudioOptions")
	for bus in ["Music", "SFX", "Voice"]:
		var slider = settings.get_node(bus + "/Volume")
		slider.set_value_no_signal(float(config.get_value("audio", bus, 80.0)))
		_set_volume(slider.value, bus, false)
		slider.value_changed.connect(_set_volume.bind(bus, true))
	reduced_effects = bool(config.get_value("display", "reduced_effects", false))
	subtitles = bool(config.get_value("display", "subtitles", true))
	settings.get_node("ReducedEffects").set_pressed_no_signal(reduced_effects)
	settings.get_node("Subtitles").set_pressed_no_signal(subtitles)
	settings.get_node("ReducedEffects").toggled.connect(_reduced)
	settings.get_node("Subtitles").toggled.connect(_subtitles)
	$BaseImpact.process_mode = Node.PROCESS_MODE_PAUSABLE
	$BaseImpact.global_position = base.global_position + Vector3.UP * 0.8
	$BaseImpact/Shield.material_override = $BaseImpact/Shield.material_override.duplicate()
	previous_health = _health()
	call_deferred("_start")

func _start() -> void:
	announce(role, "Protect the core." if role == "defender" else "Break their defenses.", 10)

func _set_volume(value: float, bus: String, save: bool) -> void:
	var index: int = AudioServer.get_bus_index(bus)
	if index >= 0: AudioServer.set_bus_volume_linear(index, value / 100.0)
	if save:
		config.set_value("audio", bus, value)
		config.save("user://presentation.cfg")

func _reduced(value: bool) -> void:
	reduced_effects = value
	config.set_value("display", "reduced_effects", value)
	config.save("user://presentation.cfg")

func _subtitles(value: bool) -> void:
	subtitles = value
	if not value: $Subtitle.hide()
	config.set_value("display", "subtitles", value)
	config.save("user://presentation.cfg")

func _health() -> int:
	var online = get_tree().current_scene
	if online != null and online.has_method("online_action"):
		return online.base_health

	return get_parent().base_health if role == "attacker" else get_parent().get_node("Gameplay/CombatReview").base_health

func announce(key: String, text: String, priority: int) -> void:
	if $Voice.playing and priority <= voice_priority: return
	var character_voice = get_parent().get_node_or_null("JetVoice/Player")
	if character_voice != null: character_voice.stop()
	$Voice.stop()
	voice_priority = priority
	$Voice.stream = load("res://assets/audio/announcer/" + key + ".wav")
	$Voice.play()
	$Subtitle.text = text
	$Subtitle.visible = subtitles

func _process(delta: float) -> void:
	$Voice.stream_paused = get_tree().paused and not finished
	$Ability.visible = not finished and not get_tree().paused
	if finished or get_tree().paused: return
	cooldown = maxf(0.0, cooldown - delta)
	active_remaining = maxf(0.0, active_remaining - delta)
	notice_time = maxf(0.0, notice_time - delta)
	$Notice.visible = notice_time > 0.0
	_check_health(_health())
	if clock.running and clock.remaining <= 60.0 and not minute_announced:
		minute_announced = true
		announce("final_minute", "One minute remaining.", 30)
		notice("FINAL MINUTE")
		hud.get_node("%TimeLabel").modulate = Color("#ffbf61")
		var music = get_parent().get_node_or_null("BattleMusic")
		if music: music.final_minute = true
	var name_text: String = "RUSH" if role == "attacker" else "OVERCHARGE"
	$Ability.text = name_text + ("  •  %.0fs" % ceilf(cooldown) if cooldown > 0.0 else "  •  READY")
	if active_remaining > 0.0: $Ability.text = name_text + " ACTIVE  •  %.0fs" % ceilf(active_remaining)
	$Ability.disabled = cooldown > 0.0 or not clock.running
	$Ability.tooltip_text = "Boost deployed troops' speed by 50% for 6 seconds." if role == "attacker" else "Select a tower, then boost its action speed by 50% for 6 seconds."
	var maximum: int = get_parent().base_maximum_health if role == "attacker" else 100
	$BaseImpact/Shield.visible = not reduced_effects and previous_health < maximum

func _check_health(health: int) -> void:
	if health < previous_health:
		base_damage += previous_health - health
		if not reduced_effects:
			$BaseImpact/Particles.restart()
			$BaseImpact/Particles.emitting = true
			$BaseImpact/Shield.material_override.set_shader_parameter("impact", 1.0)
			create_tween().tween_method(func(value: float): $BaseImpact/Shield.material_override.set_shader_parameter("impact", value), 1.0, 0.0, 0.5)
	previous_health = health
	var maximum: int = get_parent().base_maximum_health if role == "attacker" else 100
	var ratio: float = clampf(float(health) / maxi(1, maximum), 0.0, 1.0)
	$BaseImpact/Shield.material_override.set_shader_parameter("integrity", ratio)
	$BaseImpact/CoreLight.light_energy = 0.2 + ratio * 0.8
	$BaseImpact/CoreLight.light_color = Color("#3dcfff") if ratio > 0.25 else Color("#ff485f")
	if ratio <= 0.25 and health > 0 and not critical_announced:
		critical_announced = true
		announce("enemy_critical" if role == "attacker" else "own_critical", "Their core is critical!" if role == "attacker" else "Your core is critical!", 50)
		notice("ENEMY CORE CRITICAL" if role == "attacker" else "YOUR CORE IS CRITICAL")

func notice(text: String) -> void:
	$Notice.text = text
	notice_time = 2.5
	$Notice.show()

func _ability() -> void:
	var online = get_tree().current_scene
	if online != null and online.has_method("online_action"):
		var target = online.get_node("Gameplay/TowerShop/UpgradeSidebar").tower
		online.online_action("boost", {"id": online.online_id(target) if is_instance_valid(target) else 0})
		return

	if finished or get_tree().paused or not clock.running or cooldown > 0.0: return
	if role == "attacker":
		var count: int = 0
		for troop in get_tree().get_nodes_in_group("attacker_troops"):
			if troop.alive:
				troop.rush_remaining = ability_duration
				troop.rush_multiplier = ability_multiplier
				_boost_aura(troop)
				count += 1
		if count == 0:
			notice("Train some troops before using Rush.")
			return
		notice("RUSH  •  %d troops accelerated" % count)
	else:
		var sidebar = get_parent().get_node("Gameplay/TowerShop/UpgradeSidebar")
		if not sidebar.active or not is_instance_valid(sidebar.tower) or sidebar.tower.health <= 0:
			notice("Select a tower first, then use Overcharge.")
			return
		sidebar.tower.overcharge_remaining = ability_duration
		sidebar.tower.overcharge_multiplier = ability_multiplier
		sidebar.tower.get_node("ActionTimer").start(sidebar.tower.effective_interval())
		celebrate(sidebar.tower.get_node("Model"))
		_boost_aura(sidebar.tower)
		notice("OVERCHARGE  •  Tower actions accelerated")
	cooldown = ability_cooldown
	active_remaining = ability_duration
	$Confirm.play()

func _boost_aura(actor: Node3D) -> void:
	if reduced_effects: return
	var aura = preload("res://scenes/combat/boost_aura.tscn").instantiate()
	aura.duration = ability_duration
	actor.add_child(aura)

func celebrate(model: Node3D) -> void:
	if reduced_effects or not is_instance_valid(model): return
	var original: Vector3 = model.scale
	var tween := model.create_tween()
	tween.tween_property(model, "scale", original * 1.06, 0.12)
	tween.tween_property(model, "scale", original, 0.18)

func record_damage(tower: Node3D, amount: int) -> void:
	if finished or amount <= 0: return
	var key: int = tower.get_instance_id()
	if not tower_damage.has(key):
		var actor: String = {"attack": "Jet", "defense": "Arjie", "economy": "Canguit"}.get(tower.kind, "Tower")
		tower_damage[key] = {"name": actor, "damage": 0}
	tower_damage[key].damage += amount

func _question_reward(amount: int) -> void:
	question_gold += amount
	questions_correct += 1
	$Confirm.play()
	if reward_tween and reward_tween.is_valid(): reward_tween.kill()
	$GoldTravel.text = "+%d gold" % amount
	$GoldTravel.position = hud.get_node("%RewardLabel").global_position
	$GoldTravel.modulate = Color("#ffdc75")
	$GoldTravel.show()
	if reduced_effects:
		notice("+%d gold • Correct answer!" % amount)
		$GoldTravel.hide()
		return
	reward_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_STOP)
	reward_tween.tween_property($GoldTravel, "position", hud.get_node("%GoldLabel").global_position, 0.7).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	reward_tween.tween_callback($GoldTravel.hide)

func finish(won: bool, health: int) -> String:
	_check_health(health)
	finished = true
	$Ability.hide()
	$Notice.hide()
	$GoldTravel.hide()
	announce("victory" if won else "defeat", "Victory!" if won else "Defeat.", 100)
	var top_name: String = "None"
	var top_damage: int = 0
	for entry in tower_damage.values():
		if entry.damage > top_damage:
			top_damage = entry.damage
			top_name = entry.name
	if role == "attacker":
		return "Base damage: %d  •  Towers destroyed: %d\nQuestions correct: %d  •  Question gold: %d" % [base_damage, towers_destroyed, questions_correct, question_gold]
	return "Bugs defeated: %d  •  Top direct damage: %s (%d)\nQuestions correct: %d  •  Question gold: %d" % [bugs_defeated, top_name, top_damage, questions_correct, question_gold]
