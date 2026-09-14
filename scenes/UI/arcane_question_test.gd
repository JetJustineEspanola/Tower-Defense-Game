extends Control

var gold = 100
var mana = 20
var answered = false

func _ready():
	$GoldLabel.text = "Gold: " + str(gold)
	$ManaLabel.text = "Mana: " + str(mana)
	
func _on_answer_button_a_pressed():
	if answered:
		return
		
	answered = true
	gold += 25
	
	$GoldLabel.text = "Gold: " + str(gold)
	$QuestionPanel/ResultLabel.text = "Correct!"
		
	$QuestionPanel/AnswerButtonA.disabled = true
	$QuestionPanel/AnswerButtonB.disabled = true
	$QuestionPanel/AnswerButtonC.disabled = true


func _on_answer_button_b_pressed() -> void:
	if answered:
		return
		
	answered = true
	
	
	$QuestionPanel/ResultLabel.text = "Incorrect!"
	
	$QuestionPanel/AnswerButtonA.disabled = true
	$QuestionPanel/AnswerButtonB.disabled = true
	$QuestionPanel/AnswerButtonC.disabled = true


func _on_answer_button_c_pressed() -> void:
	if answered:
		return
	
	answered = true
	
	$QuestionPanel/ResultLabel.text = "Incorrect!"
	
	$QuestionPanel/AnswerButtonA.disabled = true
	$QuestionPanel/AnswerButtonB.disabled = true
	$QuestionPanel/AnswerButtonC.disabled = true


func _on_new_question_button_pressed():
	if mana < 10:
		return
		
	mana -= 10
	$ManaLabel.text = "Mana: " + str(mana)
		
	answered = false
	$QuestionPanel/ResultLabel.text = ""
		
	$QuestionPanel/AnswerButtonA.disabled = false
	$QuestionPanel/AnswerButtonB.disabled = false
	$QuestionPanel/AnswerButtonC.disabled = false


func _on_mana_timer_timeout():
	if mana < 50:
		mana += 1
		
		$ManaLabel.text = "Mana: " + str(mana)
