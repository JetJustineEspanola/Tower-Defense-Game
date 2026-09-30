extends Node3D
## Practice settings are intentionally on the scene root for easy Inspector editing.
@export_range(10, 3600, 1) var match_duration_seconds: int = 720
@export_range(0, 100000, 1) var starting_gold: int = 300

func _ready() -> void:
	var hud = $Gameplay/ResourceHUD/ArcaneQuestionTest
	var clock: MatchClock = hud.get_node("MatchClock")
	clock.duration_seconds = match_duration_seconds
	clock.start()
	hud.resources.gold = starting_gold
	hud.resources.changed.emit(hud.resources.gold, hud.resources.mana)
	hud.get_node("TopBar/Row/Brand/Tagline").text = "DEFENDER PRACTICE"
	$Gameplay/TowerShop/PracticeBug.hide()
