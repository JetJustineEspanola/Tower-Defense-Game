extends Node
@export var voice_bank: Resource
@export var character_banks: Dictionary = {}
@export var gap_seconds: float = 1.5
var elapsed: float = 0.0
var last_started: float = -100.0
var played_at: Dictionary = {}
var last_take: Dictionary = {}
var current_priority: int = -1
var last_event: String = ""
const PRIORITIES = {"placed": 2, "deployed": 2, "selected": 1, "upgraded": 3, "attack": 0, "strong_attack": 0, "hurt_light": 1, "hurt_heavy": 1, "low_health": 4, "defeated": 5, "stationed": 2, "income": 0, "guard_blocked": 2, "tower_destroyed": 4, "bombardment": 2, "phase": 3, "phase_complete": 3}
const COOLDOWNS = {"placed": 5.0, "deployed": 5.0, "selected": 6.0, "upgraded": 2.0, "attack": 10.0, "strong_attack": 10.0, "hurt_light": 8.0, "hurt_heavy": 8.0, "low_health": 15.0, "defeated": 8.0, "stationed": 30.0, "income": 8.0, "guard_blocked": 10.0, "tower_destroyed": 8.0, "bombardment": 8.0, "phase": 10.0, "phase_complete": 10.0}
@onready var experience = get_parent().get_node("Experience")
@onready var clock = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")
func _process(delta: float) -> void:
	if not clock.running or experience.get_node("Voice").playing:
		$Player.stop()
		current_priority = -1
	if not get_tree().paused: elapsed += delta
func request(event: String, actor: Node) -> bool:
	return request_for("Jet", event, actor)
func request_for(character: String, event: String, actor: Node) -> bool:
	var bank: Resource = voice_bank if character == "Jet" else character_banks.get(character)
	if bank == null or not PRIORITIES.has(event): return false
	if get_tree().paused or not clock.running or not is_instance_valid(actor): return false
	if character == "Jet":
		if not _has_property(actor, "kind") or actor.get("kind") != "attack" or actor.get("resources") != experience.hud.resources: return false
	else:
		if not _has_property(actor, "resources") or not _has_property(actor, "clock"): return false
		if actor.get("clock") != clock: return false
	if experience.get_node("Voice").playing: return false
	var priority: int = PRIORITIES[event]
	var cooldown_key: String = character + ":" + event
	if elapsed - float(played_at.get(cooldown_key, -100.0)) < COOLDOWNS[event]: return false
	if $Player.playing and priority <= current_priority: return false
	if elapsed - last_started < gap_seconds and priority <= current_priority: return false
	var clips: Array = bank.get(event)
	if clips.is_empty(): return false
	var index: int = randi_range(0, clips.size() - 1)
	if clips.size() > 1 and index == int(last_take.get(cooldown_key, -1)): index = (index + 1) % clips.size()
	$Player.stop()
	$Player.stream = clips[index]
	$Player.play()
	last_take[cooldown_key] = index
	played_at[cooldown_key] = elapsed
	# Share attack/hurt cooldowns across variations and all actors in that bank.
	if event in ["attack", "strong_attack"]:
		played_at[character + ":attack"] = elapsed
		played_at[character + ":strong_attack"] = elapsed
	if event in ["hurt_light", "hurt_heavy"]:
		played_at[character + ":hurt_light"] = elapsed
		played_at[character + ":hurt_heavy"] = elapsed
	last_started = elapsed
	current_priority = priority
	last_event = event
	return true

func _has_property(object: Object, property_name: String) -> bool:
	for property in object.get_property_list():
		if String(property.name) == property_name: return true
	return false
