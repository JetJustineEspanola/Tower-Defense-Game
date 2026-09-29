extends Control
## Scene-authored resource bar, countdown, question sidebar and local pause menu.
signal answer_submitted(correct: bool)
@export_range(1, 10000) var preview_maximum_health: int = 100
@export_range(0, 1000) var question_cost: int = 10
@export_range(1, 1000) var question_reward: int = 25
var selected_answer: int = -1
var answered: bool = false
@onready var resources: PlayerResources = $Resources
@onready var answers: Array[Button] = [%AnswerButtonA, %AnswerButtonB, %AnswerButtonC, %AnswerButtonD]

func _ready() -> void:
	resources.changed.connect(_update_resources)
	_update_resources(resources.gold, resources.mana)
	set_time_remaining($MatchClock.displayed_seconds)
	set_base_health(preview_maximum_health, preview_maximum_health)
	_refresh_question()

func _update_resources(gold: int, mana: int) -> void:
	%GoldLabel.text = str(gold)
	%ManaLabel.text = "%d / %d" % [mana, resources.maximum_mana]
	%NewQuestionButton.disabled = mana < question_cost
	%NewQuestionButton.text = "New question  /  %d mana" % question_cost

func _select_answer(index: int) -> void:
	if answered or get_tree().paused:
		return
	selected_answer = index
	%ResultLabel.text = "Answer selected. Submit when ready."
	%SubmitButton.disabled = false

func _submit_answer() -> void:
	if answered or selected_answer < 0 or get_tree().paused:
		return
	answered = true
	var correct: bool = selected_answer == 0
	if correct:
		resources.add_gold(question_reward)
		%ResultLabel.text = "Correct! +%d gold" % question_reward
	else:
		%ResultLabel.text = "Not quite. The correct answer is 14."
	_refresh_question()
	answer_submitted.emit(correct)

func _on_new_question_button_pressed() -> void:
	if get_tree().paused:
		return
	if not resources.spend_mana(question_cost):
		return
	answered = false
	selected_answer = -1
	for button in answers:
		button.set_pressed_no_signal(false)
	%ResultLabel.text = "Choose one answer, then submit."
	_refresh_question()

func _refresh_question() -> void:
	for button in answers:
		button.disabled = answered
	%SubmitButton.disabled = answered or selected_answer < 0
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
