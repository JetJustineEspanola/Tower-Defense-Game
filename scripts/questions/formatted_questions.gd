extends RefCounted
const STORE = preload("res://scripts/questions/deck_store.gd")
const FIELDS = ["TYPE", "QUESTION", "A", "B", "C", "D", "ANSWER", "CODE", "GOLD", "EXPLANATION"]
static func parse(text: String) -> Dictionary:
	if text.length() > 2000000: return {"error": "Text exceeds 2 MB."}
	var cards: Array = []
	var fields: Dictionary = {}
	var field: String = ""
	var inside: bool = false
	var title: String = "Imported questions"
	var line_number: int = 0
	for raw in text.replace("\r\n", "\n").replace("\r", "\n").trim_prefix("\ufeff").split("\n"):
		line_number += 1
		var line: String = raw.strip_edges()
		if line == "[QUESTION]":
			if inside: return {"error": "Line %d: missing [END] before the next question." % line_number}
			inside = true
			fields = {}
			field = ""
			continue
		if line == "[END]":
			if not inside: return {"error": "Line %d: [END] has no question." % line_number}
			var converted: Dictionary = _card(fields, cards.size() + 1)
			if converted.has("error"): return converted
			cards.append(converted)
			if cards.size() > 500: return {"error": "Maximum 500 questions per deck."}
			inside = false
			continue
		if not inside:
			if line.begins_with("DECK:"): title = line.substr(5).strip_edges()
			elif not line.is_empty(): return {"error": "Line %d: expected DECK: or [QUESTION]. Use the template; ordinary notes are not automatically rewritten." % line_number}
			continue
		var colon: int = line.find(":")
		var key: String = line.left(colon) if colon >= 0 else ""
		if key in FIELDS:
			if fields.has(key) and key != "ANSWER": return {"error": "Question %d: repeated %s field." % [cards.size() + 1, key]}
			field = key
			var value: String = raw.substr(raw.find(":") + 1).trim_prefix(" ")
			if key == "ANSWER":
				if not fields.has(key): fields[key] = []
				fields[key].append(value)
			else: fields[key] = value
		elif line.is_empty():
			if field == "CODE": fields[field] += "\n"
			elif field == "ANSWER": fields[field][-1] += "\n"
		elif field in ["QUESTION", "CODE", "EXPLANATION", "A", "B", "C", "D"]:
			fields[field] += ("" if str(fields[field]).is_empty() else "\n") + raw
		elif field == "ANSWER": fields[field][-1] += ("" if str(fields[field][-1]).is_empty() else "\n") + raw
		else: return {"error": "Line %d: unrecognized field or missing label." % line_number}
	if inside: return {"error": "Final question is missing [END]."}
	var enabled: Array = []
	for card in cards:
		if not card.type in enabled: enabled.append(card.type)
	var deck := {"version": 1, "id": "import_" + str(Time.get_ticks_usec()), "name": title, "enabled_types": enabled, "cards": cards, "notes": []}
	var error: String = STORE.valid(deck)
	return {"deck": deck, "error": error}
static func _card(fields: Dictionary, index: int) -> Dictionary:
	var types := {"MULTIPLE_CHOICE": "multiple_choice", "MC": "multiple_choice", "IDENTIFICATION": "identification", "CODE_FIX": "code_fix"}
	var type: String = str(fields.get("TYPE", "")).strip_edges().to_upper().replace(" ", "_")
	if not types.has(type): return {"error": "Question %d: TYPE must be MULTIPLE_CHOICE, IDENTIFICATION or CODE_FIX." % index}
	var gold: String = str(fields.get("GOLD", "25")).strip_edges()
	if not gold.is_valid_int(): return {"error": "Question %d: GOLD must be a whole number." % index}
	var answers: Array = fields.get("ANSWER", []).duplicate()
	for i in answers.size(): answers[i] = str(answers[i]).trim_suffix("\n")
	var card := {"id": "card_" + str(index), "type": types[type], "prompt": str(fields.get("QUESTION", "")).strip_edges(), "code": str(fields.get("CODE", "")).trim_suffix("\n"), "reward": int(gold), "explanation": str(fields.get("EXPLANATION", "")).strip_edges(), "answers": answers, "choices": [], "correct": -1}
	if card.type == "multiple_choice":
		if answers.size() != 1 or not str(answers[0]).strip_edges().to_upper() in ["A", "B", "C", "D"]: return {"error": "Question %d: ANSWER must be one letter, A, B, C or D." % index}
		card.correct = "ABCD".find(str(answers[0]).strip_edges().to_upper())
		for key in ["A", "B", "C", "D"]: card.choices.append(str(fields.get(key, "")).strip_edges())
	elif card.type == "code_fix" and card.code.strip_edges().is_empty(): return {"error": "Question %d: CODE is required for a code-fix card." % index}
	var error: String = STORE.valid({"name": "Check", "enabled_types": [card.type], "cards": [card]})
	return card if error.is_empty() else {"error": "Question %d: %s" % [index, error]}