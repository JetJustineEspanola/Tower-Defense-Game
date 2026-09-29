extends Node
## Presence-based combat music, shared by both local match roles.
@export_enum("defender", "attacker") var role: String = "defender"
@export_range(-40.0, 0.0) var music_volume_db: float = -5.0
@export_range(0.1, 5.0) var fade_seconds: float = 1.2
var combat_active: bool = false
var initialized: bool = false
var fade: Tween
@onready var clock: MatchClock = get_parent().get_node("Gameplay/ResourceHUD/ArcaneQuestionTest/MatchClock")

func _ready() -> void:
	$Calm.finished.connect($Calm.play)
	$Combat.finished.connect($Combat.play)
	$Check.timeout.connect(_update_music)
	# Wait until the attacker has placed its preset defenders.
	call_deferred("_update_music")

func _process(_delta: float) -> void:
	$Calm.stream_paused = get_tree().paused
	$Combat.stream_paused = get_tree().paused
	if not clock.running:
		if fade and fade.is_valid(): fade.kill()
		$Calm.stop()
		$Combat.stop()

func _update_music() -> void:
	if not clock.running or get_tree().paused: return
	var threat: bool = false
	var group: String = "placed_towers" if role == "attacker" else "combat_bugs"
	for actor in get_tree().get_nodes_in_group(group):
		if actor.is_queued_for_deletion(): continue
		if (role == "attacker" and actor.health > 0) or (role == "defender" and actor.alive):
			threat = true
			break
	if initialized and threat == combat_active: return
	initialized = true
	combat_active = threat
	if fade and fade.is_valid(): fade.kill()
	var incoming: AudioStreamPlayer = $Combat if threat else $Calm
	var outgoing: AudioStreamPlayer = $Calm if threat else $Combat
	if not incoming.playing:
		incoming.volume_db = -60.0
		incoming.play()
	fade = create_tween().set_parallel(true)
	fade.tween_property(incoming, "volume_db", music_volume_db, fade_seconds)
	fade.tween_property(outgoing, "volume_db", -60.0, fade_seconds)
	fade.chain().tween_callback(outgoing.stop)
