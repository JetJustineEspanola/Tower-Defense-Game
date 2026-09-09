extends Node

signal updated
signal command_result(sequence: int, message: String)
var simulation: BattleSimulation
var view: Dictionary = {}
var sequence: int = 0
var snapshot_clock: float = 0.0

func reset() -> void:
	simulation = null
	view.clear()
	sequence = 0
	snapshot_clock = 0.0

func begin(match_id: int, attacker: int, defender: int, duration: int) -> void:
	reset()
	simulation = BattleSimulation.new()
	simulation.start(match_id, attacker, defender, duration)

func request(action: String, payload: Dictionary = {}) -> int:
	sequence += 1
	NetworkManager.send_command(int(view.get("match_id", -1)), sequence, action, payload)
	return sequence

func _physics_process(delta: float) -> void:
	if simulation == null or not NetworkManager.is_host():
		return
	simulation.step(delta)
	snapshot_clock += delta
	if snapshot_clock >= 0.1:
		snapshot_clock = 0.0
		NetworkManager.publish_state()

func receive(snapshot: Dictionary) -> void:
	if not view.is_empty() and int(snapshot.match_id) == int(view.match_id) and int(snapshot.tick) < int(view.tick):
		return
	view = snapshot
	updated.emit()
	if view.phase == "results" and SceneRouter.current != "results":
		SceneRouter.go("results")
