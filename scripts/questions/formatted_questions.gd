extends RefCounted
const STORE = preload("res://scripts/questions/deck_store.gd")
const FIELDS = ["TYPE", "QUESTION", "A", "B", "C", "D", "ANSWER", "CODE", "GOLD", "EXPLANATION"]
const CHOICES = ["A", "B", "C", "D"]

## Parses the [QUESTION] ... [END] template. Text copied out of PDF and Word files is
## cleaned first (smart quotes, non-breaking spaces, merged markers, page numbers).
static func parse(text: String) -> Dictionary:
	if text.length() > 2000000: return {"error": "Text exceeds 2 MB."}
	var cards: Array = []
	var fields: Dictionary = {}
	var field: String = ""
	var inside: bool = false
	var title: String = "Imported questions"
	var ignored: int = 0
	for entry in _lines(STORE.clean_text(text)):
		var line_number: int = entry.number
		var raw: String = entry.text
		var line: String = raw.strip_edges()
		var marker: String = line.to_upper()
		if marker == "[QUESTION]":
			if inside: return {"error": "Line %d: missing [END] before the next question." % line_number}
			inside = true
			fields = {}
			field = ""
			continue
		if marker == "[END]":
			if not inside: return {"error": "Line %d: [END] has no question." % line_number}
			var converted: Dictionary = _card(fields, cards.size() + 1)
			if converted.has("error"): return converted
			cards.append(converted)
			if cards.size() > 500: return {"error": "Maximum 500 questions per deck."}
			inside = false
			continue
		if not inside:
			# Headers, footers and page numbers between questions are skipped.
			if marker.begins_with("DECK") and line.find(":") >= 0 and line.left(line.find(":")).strip_edges().to_upper() == "DECK":
				title = line.substr(line.find(":") + 1).strip_edges()
			elif not line.is_empty(): ignored += 1
			continue
		var key: String = _label(raw, field)
		if not key.is_empty():
			if fields.has(key) and key != "ANSWER": return {"error": "Question %d (line %d): repeated %s field." % [cards.size() + 1, line_number, key]}
			field = key
			var value: String = raw.substr(raw.find(":") + 1).trim_prefix(" ")
			if key == "ANSWER":
				if not fields.has(key): fields[key] = []
				fields[key].append(value)
			else: fields[key] = value
		elif line.is_empty():
			if field == "CODE": fields[field] += "\n"
			elif field == "ANSWER": fields[field][-1] += "\n"
			# Keep paragraph breaks in long prompts; leading/trailing ones are stripped later.
			elif field in ["QUESTION", "EXPLANATION"] and not str(fields[field]).is_empty(): fields[field] += "\n"
		elif _page_artifact(line) and not _keeps_layout(field, fields):
			continue
		elif field in ["QUESTION", "CODE", "EXPLANATION", "A", "B", "C", "D"]:
			fields[field] += ("" if str(fields[field]).is_empty() else "\n") + raw
		elif field == "ANSWER": fields[field][-1] += ("" if str(fields[field][-1]).is_empty() else "\n") + raw
		else: return {"error": "Line %d: unrecognized field or missing label. Labels are TYPE, QUESTION, A–D, ANSWER, CODE, GOLD, EXPLANATION." % line_number}
	if inside: return {"error": "Final question is missing [END]."}
	if cards.is_empty(): return {"error": "No [QUESTION] blocks found. Use the template; ordinary notes are not automatically rewritten."}
	var enabled: Array = []
	for card in cards:
		if not card.type in enabled: enabled.append(card.type)
	var deck := {"version": 1, "id": "import_" + str(Time.get_ticks_usec()), "name": title, "enabled_types": enabled, "cards": cards, "notes": []}
	var error: String = STORE.valid(deck)
	return {"deck": deck, "error": error, "ignored": ignored}

## Returns the canonical label for a "LABEL: value" line, or "" for a continuation line.
## Multi-letter labels ignore case and spaces before the colon ("Type :", "answer:").
## Single-letter choice labels must be written A:–D: so prose such as "a: ..." is kept.
## Inside CODE only exact upper-case labels end the block, so code like "type: int" stays code.
static func _label(raw: String, current: String) -> String:
	var colon: int = raw.find(":")
	if colon < 0: return ""
	var written: String = raw.left(colon).strip_edges()
	var key: String = written.to_upper()
	if not key in FIELDS: return ""
	if written == key: return key
	if key in CHOICES or current == "CODE": return ""
	return key

## Page numbers and running footers that PDF extraction places between lines.
static func _page_artifact(line: String) -> bool:
	var pattern := RegEx.new()
	pattern.compile("(?i)^(-\\s*)?(page\\s*)?\\d{1,4}(\\s*(of|/)\\s*\\d{1,4})?(\\s*-)?$")
	return pattern.search(line) != null

## Code keeps every line, including lines that look like page numbers.
static func _keeps_layout(field: String, fields: Dictionary) -> bool:
	if field == "CODE": return true
	return field == "ANSWER" and str(fields.get("TYPE", "")).strip_edges().to_upper().replace(" ", "_") == "CODE_FIX"

## Splits text into numbered lines and moves [QUESTION]/[END] markers that PDF
## extraction merged with neighbouring text onto their own lines.
static func _lines(text: String) -> Array:
	var result: Array = []
	var number: int = 0
	for raw in text.split("\n"):
		number += 1
		var rest: String = raw
		var tail: Array = []
		while true:
			var stripped: String = rest.strip_edges()
			var upper: String = stripped.to_upper()
			if stripped.length() > 10 and upper.begins_with("[QUESTION]"):
				result.append({"number": number, "text": "[QUESTION]"})
				rest = stripped.substr(10)
			elif stripped.length() > 5 and upper.begins_with("[END]"):
				result.append({"number": number, "text": "[END]"})
				rest = stripped.substr(5)
			elif stripped.length() > 5 and upper.ends_with("[END]"):
				# Trim only the right side so indentation of a final code line survives.
				tail.push_front("[END]")
				rest = rest.strip_edges(false, true)
				rest = rest.left(rest.length() - 5)
			elif stripped.length() > 10 and upper.ends_with("[QUESTION]"):
				tail.push_front("[QUESTION]")
				rest = rest.strip_edges(false, true)
				rest = rest.left(rest.length() - 10)
			else: break
		result.append({"number": number, "text": rest})
		for marker in tail: result.append({"number": number, "text": marker})
	return result

static func _card(fields: Dictionary, index: int) -> Dictionary:
	var types := {"MULTIPLE_CHOICE": "multiple_choice", "MC": "multiple_choice", "IDENTIFICATION": "identification", "CODE_FIX": "code_fix"}
	var type: String = str(fields.get("TYPE", "")).strip_edges().to_upper().replace(" ", "_").replace("-", "_")
	if not types.has(type): return {"error": "Question %d: TYPE must be MULTIPLE_CHOICE, IDENTIFICATION or CODE_FIX." % index}
	var gold: String = str(fields.get("GOLD", "25")).strip_edges()
	if not gold.is_valid_int(): return {"error": "Question %d: GOLD must be a whole number." % index}
	var answers: Array = fields.get("ANSWER", []).duplicate()
	for i in answers.size(): answers[i] = str(answers[i]).trim_suffix("\n")
	var card := {"id": "card_" + str(index), "type": types[type], "prompt": str(fields.get("QUESTION", "")).strip_edges(), "code": str(fields.get("CODE", "")).trim_suffix("\n"), "reward": int(gold), "explanation": str(fields.get("EXPLANATION", "")).strip_edges(), "answers": answers, "choices": [], "correct": -1}
	if card.type == "multiple_choice":
		if answers.size() != 1 or not str(answers[0]).strip_edges().to_upper() in CHOICES: return {"error": "Question %d: ANSWER must be one letter, A, B, C or D." % index}
		card.correct = "ABCD".find(str(answers[0]).strip_edges().to_upper())
		for key in CHOICES: card.choices.append(str(fields.get(key, "")).strip_edges())
	else:
		for key in CHOICES:
			if fields.has(key): return {"error": "Question %d: %s: choices are only used by MULTIPLE_CHOICE questions. Put that text on the QUESTION line instead." % [index, key]}
		if card.type == "code_fix" and card.code.strip_edges().is_empty(): return {"error": "Question %d: CODE is required for a code-fix card." % index}
	var error: String = STORE.valid({"name": "Check", "enabled_types": [card.type], "cards": [card]})
	return card if error.is_empty() else {"error": "Question %d: %s" % [index, error]}
