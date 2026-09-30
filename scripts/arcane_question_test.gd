extends Control
const BALANCE = preload("res://resources/attacker/combat_balance.tres")
var emergency_remaining: float = 0.0
## Scene-authored resource bar, countdown, question sidebar and local pause menu.
signal answer_submitted(correct: bool)
signal question_rewarded(amount: int)
@export_range(1, 10000) var preview_maximum_health: int = 100
@export_range(0, 1000) var question_cost: int = 10
@export_range(1, 1000) var question_reward: int = 25
var selected_answer: int = -1
var answered: bool = false
const DECK_STORE = preload("res://scripts/questions/deck_store.gd")
var question_run = preload("res://scripts/questions/question_run.gd").new()
@onready var resources: PlayerResources = $Resources
@onready var answers: Array[Button] = [%AnswerButtonA, %AnswerButtonB, %AnswerButtonC, %AnswerButtonD]

func _ready() -> void:
	resources.changed.connect(_update_resources)
	_update_resources(resources.gold, resources.mana)
	set_time_remaining($MatchClock.displayed_seconds)
	set_base_health(preview_maximum_health, preview_maximum_health)
	question_run.setup(DECK_STORE.active())
	%TypedAnswer.text_changed.connect(_refresh_question)
	_show_next_question()

func _update_resources(gold: int, mana: int) -> void:
	%GoldLabel.text = str(gold)
	%ManaLabel.text = "%d / %d" % [mana, resources.maximum_mana]
	%NewQuestionButton.disabled = (mana < question_cost and not emergency_ready()) or not $MatchClock.running
	%NewQuestionButton.text = "Emergency refresh • FREE" if emergency_ready() else "Next / skip  •  %d mana" % question_cost
	%NewQuestionButton.tooltip_text = "Base income: +%d gold every %.0fs. Free refresh below %d gold; %.0fs cooldown remaining." % [BALANCE.base_income_gold, BALANCE.base_income_seconds, BALANCE.emergency_gold_threshold, ceilf(emergency_remaining)]

func _select_answer(index: int) -> void:
	if answered or get_tree().paused:
		return
	selected_answer = index
	%ResultLabel.text = "Answer selected. Submit when ready."
	%SubmitButton.disabled = false

func _submit_answer() -> void:
	if answered or get_tree().paused or not $MatchClock.running:
		return
	if question_run.current.type == "multiple_choice" and selected_answer < 0: return
	if question_run.current.type != "multiple_choice" and %TypedAnswer.text.strip_edges().is_empty(): return
	answered = true
	var outcome: Dictionary = question_run.submit(%TypedAnswer.text, selected_answer)
	var correct: bool = outcome.correct
	if correct:
		resources.add_gold(int(outcome.gold))
		question_rewarded.emit(int(outcome.gold))
		%ResultLabel.text = "Correct! +%d gold" % int(outcome.gold)
	else:
		%ResultLabel.text = "Not quite. Try this card again next cycle."
	%ResultLabel.text += "\n" + str(question_run.current.get("explanation", ""))
	_refresh_question()
	answer_submitted.emit(correct)

func _on_new_question_button_pressed() -> void:
	if get_tree().paused or not $MatchClock.running:
		return
	if emergency_ready():
		emergency_remaining = BALANCE.emergency_refresh_seconds
	elif not resources.spend_mana(question_cost):
		return
	_show_next_question()

func emergency_ready() -> bool:
	return resources.gold < BALANCE.emergency_gold_threshold and emergency_remaining <= 0.0

func _process(delta: float) -> void:
	if get_tree().paused or not $MatchClock.running: return
	emergency_remaining = maxf(0.0, emergency_remaining - delta)
	_update_resources(resources.gold, resources.mana)

func _show_next_question() -> void:
	var card: Dictionary = question_run.next()
	answered = false
	selected_answer = -1
	%TypedAnswer.text = ""
	for button in answers:
		button.set_pressed_no_signal(false)
	var multiple: bool = card.type == "multiple_choice"
	for i in answers.size():
		answers[i].visible = multiple
		if multiple: answers[i].text = "%s   %s" % ["ABCD"[i], card.choices[i]]
	%TypedAnswer.visible = not multiple
	%TypedAnswer.placeholder_text = "Type the corrected code here" if card.type == "code_fix" else "Type your answer"
	$QuestionPanel/Scroll/Content/Type.text = str(card.type).replace("_", " ").to_upper() + "  •  CYCLE " + str(question_run.cycle)
	$QuestionPanel/Scroll/Content/QuestionLabel.text = str(card.prompt)
	$QuestionPanel/Scroll/Content/Code.visible = not str(card.get("code", "")).is_empty()
	$QuestionPanel/Scroll/Content/Code/CodeText.bbcode_enabled = false
	$QuestionPanel/Scroll/Content/Code/CodeText.text = str(card.get("code", ""))
	question_reward = int(card.get("reward", 25))
	%ResultLabel.text = "One attempt. Choose an answer, then submit." if multiple else "One attempt. Type your answer, then submit."
	_refresh_question()

func _refresh_question() -> void:
	for button in answers:
		button.disabled = answered
	%TypedAnswer.editable = not answered
	var has_answer: bool = selected_answer >= 0 if question_run.current.get("type") == "multiple_choice" else not %TypedAnswer.text.strip_edges().is_empty()
	%SubmitButton.disabled = answered or not has_answer
	%RewardLabel.text = "CORRECT ANSWER  +%d GOLD" % question_reward

func _toggle_question() -> void:
	%QuestionPanel.visible = not %QuestionPanel.visible
	%QuestionToggle.text = ">" if %QuestionPanel.visible else "<"
	%QuestionToggle.tooltip_text = "Collapse question sidebar" if %QuestionPanel.visible else "Expand question sidebar"
	%QuestionToggle.offset_left = -390.0 if %QuestionPanel.visible else -58.0
	%QuestionToggle.offset_right = -348.0 if %QuestionPanel.visible else -16.0

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not event.is_echo():
		_toggle_pause()
		get_viewport().set_input_as_handled()

func _toggle_pause() -> void:
	var paused: bool = not get_tree().paused
	get_tree().paused = paused
	%PauseOverlay.visible = paused
	if paused:
		%Resume.grab_focus()
	else:
		%PauseButton.grab_focus()

func _main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/codeborn_menu.tscn")

func _on_time_expired() -> void:
	%TimeLabel.text = "00:00"
	%TimeLabel.tooltip_text = "Time is up."

func set_time_remaining(seconds: int) -> void:
	var value: int = maxi(0, seconds)
	%TimeLabel.text = "%02d:%02d" % [floori(value / 60.0), value % 60]

func set_base_health(health: int, maximum: int) -> void:
	%HealthLabel.text = "%d / %d" % [clampi(health, 0, maxi(0, maximum)), maxi(0, maximum)]
