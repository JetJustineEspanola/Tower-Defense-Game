extends RefCounted
const DEFAULT = preload("res://resources/questions/web_starter.tres")
const TYPES = ["multiple_choice", "identification", "code_fix"]
const DIRECTORY = "user://astral_decks"
static func default_deck() -> Dictionary:
	return DEFAULT.data.duplicate(true)
static func normalize(value: String, coding: bool) -> String:
	value = value.replace("\r\n", "\n").replace("\r", "\n")
	if coding:
		# Preserve case, internal spaces and indentation; ignore terminal line breaks only.
		return value.trim_suffix("\n")
	var whitespace := RegEx.new()
	whitespace.compile("\\s+")
	return whitespace.sub(value.strip_edges().to_lower(), " ", true)
static func valid(deck: Dictionary) -> String:
	if str(deck.get("name", "")).strip_edges().is_empty(): return "Enter a deck name."
	if not deck.get("enabled_types") is Array or deck.enabled_types.is_empty(): return "Enable at least one question type."
	for type in deck.enabled_types:
		if not type in TYPES: return "Unknown question type."
	if not deck.get("cards") is Array or deck.cards.is_empty() or deck.cards.size() > 500: return "A deck needs 1–500 cards."
	var ids: Array = []
	var enabled: int = 0
	for card in deck.cards:
		if not card is Dictionary: return "Invalid card data."
		for key in ["prompt", "code", "explanation"]:
			if not card.get(key, "") is String: return "Question text must be text."
		var id: String = str(card.get("id", ""))
		if id.is_empty() or id in ids: return "Card IDs must be unique."
		ids.append(id)
		if not card.get("type") in TYPES: return "Choose a valid card type."
		if str(card.get("prompt", "")).strip_edges().is_empty(): return "Every card needs a question."
		if not card.get("reward", 25) is float and not card.get("reward", 25) is int: return "Gold must be a number."
		if float(card.get("reward", 25)) != int(card.get("reward", 25)) or int(card.get("reward", 25)) < 1 or int(card.get("reward", 25)) > 1000: return "Gold must be a whole number from 1–1000."
		if card.type in deck.enabled_types: enabled += 1
		if card.type == "multiple_choice":
			if not card.get("choices") is Array or card.choices.size() != 4: return "Multiple choice needs four options."
			var seen: Array = []
			for choice in card.choices:
				if not choice is String or choice.strip_edges().is_empty(): return "Choices cannot be blank."
				if choice.strip_edges().to_lower() in seen: return "Choices must be different."
				seen.append(choice.strip_edges().to_lower())
			if not card.get("correct") is float and not card.get("correct") is int: return "Select a correct option."
			if float(card.correct) != int(card.correct) or int(card.correct) < 0 or int(card.correct) > 3: return "Select a correct option."
		else:
			if not card.get("answers") is Array or card.answers.is_empty(): return "Typed questions need accepted answers."
			for answer in card.answers:
				if not answer is String or answer.strip_edges().is_empty(): return "Accepted answers cannot be blank."
	if enabled == 0: return "Add a card of an enabled type."
	if not deck.get("notes", []) is Array: return "Invalid reference notes."
	for note in deck.get("notes", []):
		if not note is Dictionary or not note.get("name") is String or not note.get("path") is String: return "Invalid reference note."
	return ""
static func load_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 2000000: return {}
	var result = JSON.parse_string(file.get_as_text())
	if not result is Dictionary or not valid(result).is_empty(): return {}
	return result
static func active() -> Dictionary:
	var result: Dictionary = load_file("user://astral_selected.json")
	return default_deck() if result.is_empty() else result
static func save_deck(deck: Dictionary, apply: bool) -> String:
	var error: String = valid(deck)
	if not error.is_empty(): return error
	DirAccess.make_dir_recursive_absolute(DIRECTORY)
	var name: String = str(deck.get("id", "")).validate_filename()
	if name.is_empty(): name = str(Time.get_ticks_usec())
	deck.id = name
	var file := FileAccess.open(DIRECTORY.path_join(name + ".json"), FileAccess.WRITE)
	if file == null: return "Could not save deck."
	file.store_string(JSON.stringify(deck, "\t"))
	file.close()
	if apply:
		file = FileAccess.open("user://astral_selected.json", FileAccess.WRITE)
		if file == null: return "Could not select deck."
		file.store_string(JSON.stringify(deck, "\t"))
	return ""
static func matches(card: Dictionary, answer: String, choice: int = -1) -> bool:
	if card.type == "multiple_choice": return choice == int(card.correct)
	for expected in card.answers:
		if normalize(answer, card.type == "code_fix") == normalize(expected, card.type == "code_fix"): return true
	return false
