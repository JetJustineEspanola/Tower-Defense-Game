extends Node
@export var voice_bank: Resource
@export var gap_seconds: float = 1.5
var elapsed: float = 0.0
var last_started: float = -100.0
var played_at: Dictionary = {}
var last_take: Dictionary = {}
var current_priority: int = -1
var last_event: String = ""
const PRIORITIES = {"placed": 2, "selected": 1, "upgraded": 3, "attack": 0, "strong_attack": 0, "hurt_light": 1, "hurt_heavy": 1, "low_health": 4, "defeated": 5}
const COOLDOWNS = {"placed": 5.0, "selected": 6.0, "upgraded": 2.0, "attack": 10.0, "strong_attack": 10.0, "hurt_light": 8.0, "hurt_heavy": 8.0, "low_health": 15.0, "defeated": 8.0}
@onready var experience = get_parent().get_node("Experience")
@onready var clock = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")
func _process(delta: float) -> void:
	if not clock.running or experience.get_node("Voice").playing:
		$Player.stop()
		current_priority = -1
	if not get_tree().paused: elapsed += delta
func request(event: String, actor: Node) -> bool:
	if voice_bank == null or not PRIORITIES.has(event): return false
	if get_tree().paused or not clock.running or not is_instance_valid(actor): return false
	if actor.kind != "attack" or actor.resources != experience.hud.resources: return false
	if experience.get_node("Voice").playing: return false
	var priority: int = PRIORITIES[event]
	if elapsed - float(played_at.get(event, -100.0)) < COOLDOWNS[event]: return false
	if $Player.playing and priority <= current_priority: return false
	if elapsed - last_started < gap_seconds and priority <= current_priority: return false
	var clips: Array = voice_bank.get(event)
	if clips.is_empty(): return false
	var index: int = randi_range(0, clips.size() - 1)
	if clips.size() > 1 and index == int(last_take.get(event, -1)): index = (index + 1) % clips.size()
	$Player.stop()
	$Player.stream = clips[index]
	$Player.play()
	last_take[event] = index
	played_at[event] = elapsed
	# Share attack/hurt cooldowns across variations and all Jet towers.
	if event in ["attack", "strong_attack"]:
		played_at.attack = elapsed
		played_at.strong_attack = elapsed
	if event in ["hurt_light", "hurt_heavy"]:
		played_at.hurt_light = elapsed
		played_at.hurt_heavy = elapsed
	last_started = elapsed
	current_priority = priority
	last_event = event
	return true