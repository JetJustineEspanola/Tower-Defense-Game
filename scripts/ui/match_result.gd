extends CanvasLayer
## Shared scene-authored result UI for both local roles.
const VICTORY = preload("res://assets/ui/results/victory.png")
const DEFEAT = preload("res://assets/ui/results/defeat.png")
var completed: bool = false

func _ready() -> void:
	$Screen/Content/Buttons/Home.pressed.connect(_home)
	$Screen/Content/Buttons/Again.pressed.connect(_again)

func present(won: bool, role: String, clock: MatchClock, wallet: PlayerResources, health: int, maximum: int) -> void:
	if completed: return
	completed = true
	var experience = get_parent().get_node_or_null("Experience")
	if experience:
		$Screen/Content/Highlights.text = experience.finish(won, health)
	clock.running = false
	var accent := Color("#46d9ff") if won else Color("#ff557e")
	$Screen/Background.texture = VICTORY if won else DEFEAT
	$Screen/Brand.modulate = accent
	$Screen/Motto.modulate = accent
	$Screen/Content/Banner/Text/Title.text = "VICTORY" if won else "DEFEAT"
	$Screen/Content/Banner/Text/Title.add_theme_color_override("font_shadow_color", accent)
	var message: String
	if role == "attacker":
		message = "ENEMY BASE DESTROYED" if won else "TIME EXPIRED • ENEMY BASE SURVIVED"
	else:
		message = "TIME COMPLETE • BASE SECURED" if won else "YOUR BASE HAS FALLEN"
	$Screen/Content/Banner/Text/Subtitle.text = message
	var elapsed: int = maxi(0, floori(clock.duration_seconds - clock.remaining))
	$Screen/Content/Stats/Row/Time/Value.text = "%02d:%02d" % [elapsed / 60, elapsed % 60]
	$Screen/Content/Stats/Row/Gold/Value.text = str(wallet.total_gold_earned)
	$Screen/Content/Stats/Row/Base/Caption.text = "ENEMY BASE HEALTH" if role == "attacker" else "YOUR BASE HEALTH"
	$Screen/Content/Stats/Row/Base/Value.text = "%d / %d" % [health, maximum]
	$Screen/Content/TipPanel/Tip.text = "Great strategy. On to a brighter tomorrow!" if won else ("TIP  •  Send Ronel behind your siege troops and invest in upgrades." if role == "attacker" else "TIP  •  Cover the path with attack towers and use guards to stall enemies.")
	$Screen/Content/Buttons/Again.text = "↻  PLAY AGAIN" if won else "↻  RETRY"
	for panel in [$Screen/Content/Banner, $Screen/Content/Stats, $Screen/Content/TipPanel]:
		var style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
		style.border_color = accent.darkened(0.25)
		style.shadow_color = Color(accent, 0.22)
		style.bg_color = Color("#061224") if won else Color("#200912")
		panel.add_theme_stylebox_override("panel", style)
	for button in [$Screen/Content/Buttons/Home, $Screen/Content/Buttons/Again]:
		for state in ["normal", "hover", "pressed", "focus"]:
			var style: StyleBoxFlat = $Screen/Content/Banner.get_theme_stylebox("panel").duplicate()
			style.bg_color = accent.darkened(0.65 if state == "normal" else 0.35)
			button.add_theme_stylebox_override(state, style)
	# Freeze gameplay, including remaining training and mana regeneration.
	get_tree().paused = true
	show()
	$Screen/Content/Buttons/Again.grab_focus()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()

func _again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _home() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/codeborn_menu.tscn")
