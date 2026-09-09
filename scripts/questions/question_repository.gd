extends Node

const CUSTOM_PATH: String = "user://questions.json"
var questions: Array = []
var last_error: String = ""

func _ready() -> void:
	questions = JSON.parse_string(FileAccess.get_file_as_string("res://resources/data/questions.json"))
	if FileAccess.file_exists(CUSTOM_PATH):
		var custom: Variant = JSON.parse_string(FileAccess.get_file_as_string(CUSTOM_PATH))
		last_error = validate_pack(custom)
		if last_error.is_empty():
			questions = custom

func validate_pack(data: Variant) -> String:
	if not data is Array or data.is_empty() or data.size() > 500:
		return "Pack must contain 1 to 500 questions."
	var ids: Array[String] = []
	for item: Variant in data:
		if not item is Dictionary:
			return "Each question must be an object."
		for key: String in ["id", "type", "difficulty", "prompt", "explanation", "language", "language_version"]:
			if not item.get(key) is String or item[key].strip_edges().is_empty() or item[key].length() > 2000:
				return "Missing or invalid text field: " + key
		if item.id in ids:
			return "Duplicate question ID: " + item.id
		ids.append(item.id)
		if item.type not in ["multiple_choice", "identification", "coding_fix"] or item.difficulty not in ["easy", "medium", "hard"]:
			return "Unsupported question type or difficulty."
		if item.language != "GDScript" or item.language_version != "4.6":
			return "This pack supports GDScript 4.6 only."
		if not item.get("reward") is float and not item.get("reward") is int:
			return "Reward must be a number."
		if float(item.reward) != floorf(float(item.reward)) or int(item.reward) < 1 or int(item.reward) > 60:
			return "Reward must be an integer from 1 to 60."
		if not item.get("answers") is Array or item.answers.is_empty():
			return "At least one accepted answer is required."
		for answer: Variant in item.answers:
			if not answer is String or answer.strip_edges().is_empty() or answer.length() > 500:
				return "Accepted answers must be nonempty text, up to 500 characters."
		if item.type == "multiple_choice":
			if not item.get("options") is Array or item.options.size() != 4 or item.answers.size() != 1:
				return "Multiple Choice needs four options and one answer."
			var choices: Array[String] = []
			for option: Variant in item.options:
				if not option is String or option.strip_edges().is_empty() or option.length() > 500 or option in choices:
					return "Options must be four distinct nonempty strings."
				choices.append(option)
			if item.answers[0] not in choices:
				return "The accepted answer must match an option."
		if item.type == "coding_fix" and item.prompt.count("___") != 1:
			return "Coding Fix must contain exactly one ___ blank."
	return ""

func save_pack(text: String) -> String:
	if NetworkManager.active:
		return "Leave the network session before editing questions."
	if text.length() > 1000000:
		return "Pack exceeds 1 MB."
	var data: Variant = JSON.parse_string(text)
	var problem: String = validate_pack(data)
	if not problem.is_empty():
		return problem
	var file: FileAccess = FileAccess.open(CUSTOM_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		return "Cannot write question pack."
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	var error: Error = DirAccess.rename_absolute(CUSTOM_PATH + ".tmp", CUSTOM_PATH)
	if error != OK:
		return "Cannot replace question pack (%s)." % error
	questions = data
	return ""

func public_question(index: int) -> Dictionary:
	var question: Dictionary = questions[index].duplicate(true)
	question.erase("answers")
	question.erase("explanation")
	return question

func is_correct(index: int, answer: String) -> bool:
	var q: Dictionary = questions[index]
	for accepted: String in q.answers:
		if q.type == "identification":
			if accepted.strip_edges().to_lower() == answer.strip_edges().to_lower():
				return true
		elif accepted.strip_edges() == answer.strip_edges():
			return true
	return false
