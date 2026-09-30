extends Node
const BUG = preload("res://scenes/towers/combat_bug.tscn")
@onready var hud = get_node("../ResourceHUD/ArcaneQuestionTest")
@onready var route: Path3D = get_node("../EnemyPath")
var base_health: int = 100
var ended: bool = false
func _ready() -> void:
	if not hud.is_node_ready(): await hud.ready
	hud.get_node("MatchClock").expired.connect(_timeout)
func _timeout() -> void:
	_finish(base_health > 0)
func _finish(won: bool) -> void:
	if ended: return
	ended = true
	get_node("../../MatchResult").present(won, "defender", hud.get_node("MatchClock"), hud.resources, base_health, 100)
func spawn_bug() -> void:
	if get_tree().paused or not hud.get_node("MatchClock").running: return
	if route.get_child_count() >= 30: return
	var bug = BUG.instantiate()
	bug.clock = hud.get_node("MatchClock")
	bug.arrived.connect(_arrived)
	route.add_child(bug)
func _arrived(damage: int = 10) -> void:
	if ended or not hud.get_node("MatchClock").running: return
	var health_before: int = base_health
	base_health = maxi(0, base_health - damage)
	if damage > 0: get_node("../AlliedBase/BaseFeedback").hit(health_before, base_health, true)
	get_node("../AlliedBase/BaseFeedback").set_health(base_health, 100)
	hud.set_base_health(base_health, 100)
	if base_health == 0:
		_finish(false)
