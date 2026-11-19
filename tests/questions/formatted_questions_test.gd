extends SceneTree
## Run: godot --headless --path . -s res://tests/questions/formatted_questions_test.gd
const FORMAT = preload("res://scripts/questions/formatted_questions.gd")
const STORE = preload("res://scripts/questions/deck_store.gd")
var failures := 0
var base := ""

func _initialize() -> void:
	base = FileAccess.get_file_as_string("res://resources/questions/import_template.txt")
	_expect(not base.is_empty(), "Template file is readable")
	_ok("Template", base, 3)
	_ok("Windows line endings", base.replace("\n", "\r\n"), 3)
	_ok("Page number between questions", base.replace("[END]\n\n[QUESTION]\nTYPE: IDENTIFICATION", "[END]\n2\n[QUESTION]\nTYPE: IDENTIFICATION"), 3)
	_ok("Header text before first question", "Midterm Review\nProf. Santos\n" + base, 3)
	_ok("Non-breaking space after marker", base.replace("[QUESTION]", "[QUESTION] "), 3)
	_ok("Non-breaking space after colon", base.replace("TYPE: IDENTIFICATION", "TYPE: IDENTIFICATION"), 3)
	_ok("Lowercase labels", base.replace("TYPE:", "Type:").replace("EXPLANATION:", "Explanation:"), 3)
	_ok("Marker merged with first label", base.replace("[QUESTION]\nTYPE: MULTIPLE_CHOICE", "[QUESTION] TYPE: MULTIPLE_CHOICE"), 3)
	_ok("[END] merged with previous line", base.replace("hyperlinks.\n[END]", "hyperlinks. [END]"), 3)

	var footer: Dictionary = _ok("Page footer inside a question", base.replace("GOLD: 25\nEXPLANATION: CSS", "GOLD: 25\nPage 1 of 3\nEXPLANATION: CSS"), 3)
	if footer.has("deck"): _expect(not "Page" in str(footer.deck.cards[1].explanation), "Footer is not copied into the explanation")

	var spaced: Dictionary = _ok("Space before colon", base.replace("ANSWER: Cascading Style Sheets\n", "ANSWER : Cascading Style Sheets\n"), 3)
	if spaced.has("deck"):
		_expect(spaced.deck.cards[1].answers.size() == 2, "'ANSWER :' is read as an answer")
		_expect(not "ANSWER" in str(spaced.deck.cards[1].prompt), "Answer does not leak into the question")

	var quoted: Dictionary = _ok("Smart quotes", base.replace("ANSWER: p { color: red; }", "ANSWER: p { content: “red”; }"), 3)
	if quoted.has("deck"):
		_expect(STORE.matches(quoted.deck.cards[2], "p { content: \"red\"; }"), "Straight quotes match a smart-quoted answer")

	var stray := base.replace("QUESTION: What does CSS stand for?", "QUESTION: Fill in:\nA: the acronym")
	_expect(not str(FORMAT.parse(stray).get("error", "")).is_empty(), "A: on a non multiple-choice card is reported, not silently stored")

	var code := "[QUESTION]\nTYPE: CODE_FIX\nQUESTION: Fix the type hint.\nCODE: def f(x):\n    type: int = 2\n    return 2\nANSWER: def f(x):\n    return 2\n[END]"
	var code_result: Dictionary = _ok("Code keeps lowercase label-like lines and numbers", code, 1)
	if code_result.has("deck"):
		_expect(code_result.deck.cards[0].code == "def f(x):\n    type: int = 2\n    return 2", "Code text is unchanged")
		_expect(code_result.deck.cards[0].answers[0] == "def f(x):\n    return 2", "Code answer keeps indentation")

	var paragraphs: Dictionary = _ok("Paragraph break in question", base.replace("QUESTION: What does CSS stand for?", "QUESTION: Read this.\n\nWhat does CSS stand for?"), 3)
	if paragraphs.has("deck"): _expect(paragraphs.deck.cards[1].prompt == "Read this.\n\nWhat does CSS stand for?", "Blank line inside a question is kept")

	_expect(not str(FORMAT.parse("Just my lecture notes\nNothing formatted").get("error", "")).is_empty(), "Plain notes with no [QUESTION] blocks are rejected")
	print("FAIL: %d formatted question check(s)" % failures if failures else "PASS: formatted question import")
	quit(1 if failures else 0)

func _ok(label: String, text: String, count: int) -> Dictionary:
	var result: Dictionary = FORMAT.parse(text)
	var error: String = str(result.get("error", ""))
	_expect(error.is_empty() and result.deck.cards.size() == count, "%s parses %d cards%s" % [label, count, "" if error.is_empty() else " (" + error + ")"])
	return result

func _expect(condition: bool, label: String) -> void:
	if condition: return
	failures += 1
	push_error(label)
	print("  x ", label)
