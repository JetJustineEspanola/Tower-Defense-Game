extends Control
signal cards_imported(deck: Dictionary)
const FORMAT = preload("res://scripts/questions/formatted_questions.gd")
var candidate: Dictionary = {}
var process_id: int = -1
var job_path: String = ""
var start_time: int = 0
@onready var text_input: TextEdit = $Center/Panel/Margin/Content/Text
@onready var status: Label = $Center/Panel/Margin/Content/Status
func _ready() -> void:
	get_ok_button().text = "Add questions to deck"
	get_ok_button().disabled = true
	get_ok_button().pressed.connect(_accept)
	$Center/Panel/Margin/Content/Buttons/Cancel.pressed.connect(hide)
	$Center/Panel/Margin/Content/Actions/Template.pressed.connect(func(): text_input.text = FileAccess.get_file_as_string("res://resources/questions/import_template.txt"); _invalidate())
	$Center/Panel/Margin/Content/Actions/Paste.pressed.connect(func(): text_input.text = DisplayServer.clipboard_get(); _invalidate())
	$Center/Panel/Margin/Content/Actions/File.pressed.connect(func(): $File.popup_centered(Vector2i(800, 520)))
	$File.file_selected.connect(_load_file)
	$Center/Panel/Margin/Content/Actions/Review.pressed.connect(review)
	text_input.text_changed.connect(_invalidate)
	visibility_changed.connect(func():
		if not visible: _cancel_job()
		else: pass)
func _invalidate() -> void:
	candidate = {}
	get_ok_button().disabled = true
	status.text = "Use the template labels. Review before adding. PDF code spacing must be checked."
func review() -> void:
	if process_id > 0: return
	var result: Dictionary = FORMAT.parse(text_input.text)
	candidate = result.get("deck", {}) if str(result.get("error", "")).is_empty() else {}
	get_ok_button().disabled = candidate.is_empty()
	if candidate.is_empty(): status.text = str(result.get("error", "Invalid format.")); return
	var counts := {"multiple_choice": 0, "identification": 0, "code_fix": 0}
	for card in candidate.cards: counts[card.type] += 1
	status.text = "Ready: %d multiple choice, %d identification, %d code fix. Adds to your current deck; review answers in the editor before Use this deck." % [counts.multiple_choice, counts.identification, counts.code_fix]
func _accept() -> void:
	if not candidate.is_empty():
		cards_imported.emit(candidate.duplicate(true))
		hide()
func _load_file(path: String) -> void:
	if process_id > 0: return
	_invalidate()
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 20000000: status.text = "Choose a readable file below 20 MB."; return
	if path.get_extension().to_lower() == "txt":
		if file.get_length() > 2000000: status.text = "Text exceeds 2 MB."; return
		text_input.text = file.get_as_text()
		_invalidate()
		review()
		return
	if not path.get_extension().to_lower() in ["pdf", "docx"]: status.text = "Choose PDF, DOCX or TXT."; return
	var helper: String = ProjectSettings.globalize_path("res://tools/astral_import/bin/astral_extract.exe")
	if not OS.has_feature("editor"): helper = OS.get_executable_path().get_base_dir().path_join("tools/astral_import/bin/astral_extract.exe")
	if not FileAccess.file_exists(helper): status.text = "Offline importer is missing. Paste text instead, or restore tools/astral_import beside the game."; return
	_invalidate()
	job_path = "user://astral_extract_" + str(Time.get_ticks_usec()) + ".json"
	process_id = OS.create_process(helper, [path, ProjectSettings.globalize_path(job_path)], false)
	start_time = Time.get_ticks_msec()
	status.text = "Reading document locally..."
	if process_id <= 0: status.text = "Could not start importer. Paste the document text instead."
func _process(_delta: float) -> void:
	text_input.editable = process_id <= 0
	for button in $Center/Panel/Margin/Content/Actions.get_children(): button.disabled = process_id > 0
	if process_id <= 0: return
	if Time.get_ticks_msec() - start_time > 20000:
		_cancel_job()
		status.text = "Reading timed out. Try a smaller document or paste text."
	elif not OS.is_process_running(process_id):
		process_id = -1
		var result = JSON.parse_string(FileAccess.get_file_as_string(job_path)) if FileAccess.file_exists(job_path) else null
		_clear_output()
		if not result is Dictionary: status.text = "Could not read this document. Try pasting its selectable text."; return
		if not str(result.get("error", "")).is_empty(): status.text = str(result.error); return
		text_input.text = str(result.get("text", ""))
		review()
func _clear_output() -> void:
	if not job_path.is_empty():
		for path in [job_path, job_path.get_basename() + ".tmp"]:
			if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	job_path = ""
func _cancel_job() -> void:
	if process_id > 0 and OS.is_process_running(process_id): OS.kill(process_id)
	process_id = -1
	_clear_output()
func _exit_tree() -> void: _cancel_job()
func popup_centered(_size: Vector2i = Vector2i.ZERO) -> void: show()
func get_ok_button() -> Button: return $Center/Panel/Margin/Content/Buttons/Add
